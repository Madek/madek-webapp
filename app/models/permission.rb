# -*- encoding : utf-8 -*-
class Permission < ActiveRecord::Base
  
  class Actions
    attr_accessor :keys
    
    def initialize(attributes = {})
      @keys ||= {}
      attributes.each_pair do |key, value|
        @keys[key] = value
      end
    end

    def set_actions(hash)
      hash.each_pair { |key, value| set_action(key,value) }
    end

    private

    # @args: key as symbol; value as boolean, symbol or nil
    def set_action(key, value)
      case value.class.name
        when "NilClass"
          @keys.delete(key.to_sym)
        when "TrueClass", "Symbol"
          @keys[key.to_sym] = value
        else
          @keys[key.to_sym] = false
      end
    end

  end
  
#################################################
  
  belongs_to :subject, :polymorphic => true 
  belongs_to :resource, :polymorphic => true
  
  serialize :actions_object #, Actions
  validates_presence_of :actions_object
  validates_uniqueness_of :subject_id, :scope => [:subject_type, :resource_id, :resource_type]

  #old#precedence problem# default_scope order("created_at DESC")
  scope :with_subject, where("subject_id IS NOT NULL AND subject_type IS NOT NULL")

  # TODO validate not empty actions_object
  after_initialize do |record|
    record.actions_object = Actions.new unless actions_object
  end
  
  after_save :invalidate_cache
  before_destroy :invalidate_cache
  
# Returns the hash of assigned permissions
  def actions # TODO rename to .real_action or .hard_action or .assigned_actions or .stored_actions
    actions_object.keys
  end

  # TODO refactor to Permission.merged_actions (but prevent fetching record twice)
# returns hash of all actions, correctly merged
  def merged_actions
    self.class.resource_default_actions(resource).merge(actions)
  end

  def set_actions(hash)
    actions_object.set_actions(hash)
    save
    resource.sphinx_reindex if resource.try(:respond_to?, :sphinx_reindex) and subject.nil? # OPTIMIZE after_save ??
  end

  private

  # Returns key value: boolean, symbol or nil
  def action(key)
    merged_actions[key.to_sym]
  end

  def invalidate_cache
    #regex = /permissions\/#{subject_type}_#{subject_id}\/#{resource_type}_#{resource_id}\/actions.*/
    regex = /permissions.*/
    Permission.delete_matched_cached_keys(regex)
  end


##################################################
  class << self

    # OPTIMIZE could be the subject argument a Group ?? or it's always a User ??
    # is a subject authorized to perform action on a resource?
    # returns true or false
    def authorized?(subject, action, resource)
      # TODO default manage permission for associated user (owner) ?? 
      #return true if action == :manage and subject == resource.user
      
      b = merged_actions(subject, resource)[action]
      # TODO cache b
      if b.is_a?(Symbol)
        case b
          when :logged_in_users
            !!subject # returning false if subject is not defined
          else
            false # action denied if not recognized string
        end
      else
        !!b # force to boolean
      end
    end

    def resource_viewable_only_by_user?(resource, subject)
      all = cached_permissions_by(resource)
      default = all.select {|p| p.subject.nil? }
      without_default = all - default
      without_default.size == 1 and !default.first.actions[:view] and without_default.first.subject.id == subject.id
    end
  
    # set up the default system actions
    def init(reset = false)
      return 0 unless reset or count == 0
      delete_all
  
      p = new
      p.set_actions(DEFAULT_ACTION_PERMISSIONS)
  
      return count
    end
    
    #################################################
  
    # Lowest level of permission defaults.
    def system_default_actions
      # NOTE cache tree structure: "permissions/subject_type_id/resource_type_id/actions/action_key"
      key = "permissions/_/_/actions"
      Rails.cache.fetch(key, :expires_in => 10.minutes) do
        p = where(:subject_id => nil, :subject_type => nil, :resource_type => nil, :resource_id => nil).first
        p ? p.actions : {}
      end
    end
  
    def resource_default_actions(resource)
      #p = resource.default_permission
      p = cached_permissions_by(resource).detect {|x| x.subject.nil? }
      system_default_actions.merge(p ? p.actions : {})
    end
 
    def cached_permissions_by(resource)
      key = "permissions/_/#{resource.class}_#{resource.id}/actions"
      Rails.cache.fetch(key, :expires_in => 10.minutes) do
        add_to_cached_keys(key)
        resource.permissions.all
      end
    end
    
    #################################################

#   private
    
    # returns the whole permissions hashes all merged in correct order.
    def merged_actions(subject, resource)
       actions = resource_default_actions(resource)
      
      if subject
        if subject.class == User # OPTIMIZE could be the subject argument a Group ?? 
          #group_permissions = resource.permissions.where(:subject_type => "Group", :subject_id => subject.group_ids)
          group_permissions = cached_permissions_by(resource).select {|x| x.subject_type == "Group" and subject.group_ids.include?(x.subject_id) }
          group_permissions.each do |group_permission|
            group_permission.actions.each_pair do |k,v|
              actions[k] = (actions[k] or v)
            end
          end
        end
        
        #perm_subject_resource = resource.permissions.where(:subject_type => subject.class.base_class.name, :subject_id => subject.id).first
        perm_subject_resource = cached_permissions_by(resource).detect {|x| x.subject_type == subject.class.base_class.name and x.subject_id == subject.id }
        actions = actions.merge(perm_subject_resource.actions) if perm_subject_resource
      end
      actions
    end

    #####
    # TODO move to an initializer or use
    # http://railsforum.com/viewtopic.php?id=42738
      def cached_keys
        Rails.cache.read("cached_keys") || []
      end
  
      def cached_keys=(keys)
        Rails.cache.write("cached_keys", keys)
      end
  
      def add_to_cached_keys(key)
        self.cached_keys = (cached_keys + [key]) unless cached_keys.include?(key)
      end
      
      def delete_matched_cached_keys(regex)
        matched_keys = cached_keys.select {|v| v =~ regex }
        matched_keys.each do |key|
          Rails.cache.delete(key)
        end
        self.cached_keys = (cached_keys - matched_keys)
      end
    #
    #####

    def accessible_by_user(resource_type, user, action = :view)
      key = "permissions/#{user.class}_#{user.id}/#{resource_type}_/actions/#{action}"
      Rails.cache.fetch(key, :expires_in => 10.minutes) do
        add_to_cached_keys(key)
        
        #1+3
        user_groups_true = select(:resource_id).
                                where(:resource_type => resource_type).
                                where("(subject_type = 'Group' AND subject_id IN (?)) OR (subject_type = 'User' AND subject_id = ?)", user.groups, user.id).
                                where("actions_object LIKE '%#{action}: true%'").
                                collect(&:resource_id).uniq
        
        #2
        user_false = user.permissions.select(:resource_id).
                                  where(:resource_type => resource_type).
                                  where("actions_object LIKE '%#{action}: false%'").
                                  collect(&:resource_id).uniq
      
      
        #5
        public_true = select(:resource_id).
                                  where(:resource_type => resource_type).
                                  where(:subject_type => nil).
                                  where("actions_object LIKE '%#{action}: true%' OR actions_object LIKE '%#{action}: :logged_in_users%'").
                                  collect(&:resource_id).uniq
        
        
        #2+4
        user_groups_false = select(:resource_id).
                                  where(:resource_type => resource_type).
                                  where("(subject_type = 'Group' AND subject_id IN (?)) OR (subject_type = 'User' AND subject_id = ?)", user.groups, user.id).
                                  where("actions_object LIKE '%#{action}: false%'").
                                  collect(&:resource_id).uniq
  
        ((user_groups_true - user_false) + (public_true - user_groups_false)).uniq
      end
    end

  end


end
