# -*- encoding : utf-8 -*-
class Permission < ActiveRecord::Base
  
  ACTIONS = [:view, :edit, :hi_res, :manage]
  
  belongs_to :subject, :polymorphic => true 
  belongs_to :resource, :polymorphic => true
  
  validates_numericality_of :action_bits, :action_mask
  validates_numericality_of :action_mask, :greater_than => 0, :unless => Proc.new { |resource| resource_type.nil? }  
  validates_uniqueness_of :subject_id, :scope => [:subject_type, :resource_id, :resource_type]

  #old#precedence problem# default_scope order("created_at DESC")

  after_save :invalidate_cache
  before_destroy :invalidate_cache
  
  # Returns the hash of assigned permissions #1504# TODO return directly the integer (bits & mask)
  def actions
    h = {}
    ACTIONS.each_with_index do |a, i|
      j = 2 ** i
      h[a] = !(j & action_bits & action_mask).zero? 
    end
    h
  end

#1504#
  # TODO refactor to Permission.merged_actions (but prevent fetching record twice)
  # returns hash of all actions, correctly merged
#  def merged_actions
#    self.class.resource_default_actions(resource).merge(actions)
#  end

  def set_actions(hash)
    hash.each_pair do |key, value|
      i = ACTIONS.index(key.to_sym)
      next unless i
      j = 2 ** i
      value = (value == "true" ? true : false) if value.is_a? String 
      case value
        when nil
          self.action_bits &= ~j
          self.action_mask &= ~j
        when true
          self.action_bits |= j
          self.action_mask |= j
        when false
          self.action_bits &= ~j
          self.action_mask |= j
      end
    end
    if action_mask.zero? and not resource_type.nil? # TODO validation ???
      destroy
    else
      save
    end
  end

  private

#old#??
  # Returns key value: boolean or nil
#  def action(key)
#    merged_actions[key.to_sym]
#  end

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
      # TODO cache b ??
      !!b # force to boolean
    end

    def resource_viewable_only_by_user?(resource, subject)
      all = cached_permissions_by(resource)
      default = all.detect {|p| p.subject.nil? }
      without_default = all - [default]
      without_default.size == 1 and (default.nil? or !default.actions[:view]) and without_default.first.subject.id == subject.id #1504#
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
        p ? p.actions : {} #1504#
      end
    end
  
    def resource_default(resource)
      #old#1504# p = resource.default_permission
      cached_permissions_by(resource).detect {|x| x.subject.nil? }
    end

    def resource_default_actions(resource)
      p = resource_default(resource)
      system_default_actions.merge(p ? p.actions : {}) #1504#
    end
 
    def cached_permissions_by(resource)
      key = "permissions/_/#{resource.class}_#{resource.id}/actions"
      Rails.cache.fetch(key, :expires_in => 10.minutes) do
        add_to_cached_keys(key)
        p = resource.permissions.all
        p << resource.permissions.build(:subject => nil) unless p.any? {|x| x.subject.nil?}
        p
      end
    end
    
    #################################################
    
    def compare(resources)
      combined_permissions = {"User" => [], "Group" => [], "public" => {}}
      permissions = resources.map(&:permissions).flatten

      combined_permissions.keys.each do |type|
        case type
          when "User", "Group"
            subject_permissions = permissions.select {|p| p.subject_type == type}
            subject_permissions.map(&:subject).uniq.each do |subject|
              subject_info = {:id => subject.id, :name => subject.to_s, :type => type}
              ACTIONS.each do |key|
                subject_info[key] = case subject_permissions.select {|p| p.subject_id == subject.id and p.actions[key] == true }.size #1504#
                  when resources.size
                    true
                  when 0
                    false
                  else
                    :mixed
                end  
              end
              combined_permissions[type] << subject_info
            end
          else
            default_permissions = permissions.select {|p| p.subject_type.nil? }
            combined_permissions[type][:type] = "nil"
            combined_permissions[type][:name] = "Öffentlich"
            keys.each do |key|
              combined_permissions[type][key] = case default_permissions.select {|p| p.actions[key] == true }.size #1504#
                when resources.size
                  true
                when 0
                  false
                else
                  :mixed
              end  
            end
        end
      end

      return combined_permissions
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
            group_permission.actions.each_pair do |k,v| #1504#
              actions[k] = (actions[k] or v)
            end
          end
        end
        
        #perm_subject_resource = resource.permissions.where(:subject_type => subject.class.base_class.name, :subject_id => subject.id).first
        perm_subject_resource = cached_permissions_by(resource).detect {|x| x.subject_type == subject.class.base_class.name and x.subject_id == subject.id }
        actions = actions.merge(perm_subject_resource.actions) if perm_subject_resource #1504#
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

    def accessible_by_all(resource_type, action = :view)
      key = "permissions/_/#{resource_type}_/actions/#{action}"
      Rails.cache.fetch(key, :expires_in => 10.minutes) do
        add_to_cached_keys(key)
        i = 2 ** ACTIONS.index(action)

        select(:resource_id).
            where(:resource_type => resource_type, :subject_type => nil).
            where("action_bits & #{i} AND action_mask & #{i}").
            collect(&:resource_id).uniq
      end
    end

    def accessible_by_user(resource_type, user, action = :view)
      key = "permissions/#{user.class}_#{user.id}/#{resource_type}_/actions/#{action}"
      Rails.cache.fetch(key, :expires_in => 10.minutes) do
        add_to_cached_keys(key)
        i = 2 ** ACTIONS.index(action)
        
        #1+3
        user_groups_true = select(:resource_id).
                                where(:resource_type => resource_type).
                                where("(subject_type = 'Group' AND subject_id IN (?)) OR (subject_type = 'User' AND subject_id = ?)", user.groups, user.id).
                                where("action_bits & #{i} AND action_mask & #{i}").
                                collect(&:resource_id).uniq
        
        #2
        user_false = user.permissions.select(:resource_id).
                                  where(:resource_type => resource_type).
                                  where("(NOT action_bits & #{i}) AND action_mask & #{i}").
                                  collect(&:resource_id).uniq
      
      
        #5
        public_true = accessible_by_all(resource_type, action)
        
        
        #2+4
        user_groups_false = select(:resource_id).
                                  where(:resource_type => resource_type).
                                  where("(subject_type = 'Group' AND subject_id IN (?)) OR (subject_type = 'User' AND subject_id = ?)", user.groups, user.id).
                                  where("(NOT action_bits & #{i}) AND action_mask & #{i}").
                                  collect(&:resource_id).uniq
  
        ((user_groups_true - user_false) + (public_true - user_groups_false)).uniq
      end
    end

    def assign_manage_to(subject, resource)
      @subject = subject
      @i = 2 ** ACTIONS.index(:manage)
      
      def assign_for(resource)
        resource.permissions.where("action_bits & #{@i} AND action_mask & #{@i}").first.set_actions({:manage => false})
        resource.permissions.find_or_create_by_subject_type_and_subject_id(@subject.class.base_class.name, @subject.id).set_actions({:view => true, :edit => true, :hi_res => true, :manage => true})
      end
      
      if resource.is_a?(Media::Set)
        assign_for(resource)
        resource.media_entries.each do |me|
          assign_for(me)
        end
      elsif resource.is_a?(MediaEntry)
        assign_for(resource)
      end
    end

  end


end
