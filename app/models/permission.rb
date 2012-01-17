# -*- encoding : utf-8 -*-
class Permission < ActiveRecord::Base
  
  ACTIONS = [:view, :edit, :hi_res, :manage] # view = 2^0 = 1; edit = 2^1 = 2; hi_res = 2^2 = 4; manage = 2^3 = 8
  
  belongs_to :subject, :polymorphic => true 
  belongs_to :media_resource
  
  validates_numericality_of :action_bits, :action_mask
  validates_numericality_of :action_mask, :greater_than => 0, :unless => Proc.new { |record| record.media_resource_id.nil? }  
  validates_uniqueness_of :subject_id, :scope => [:subject_type, :media_resource_id]

  #old#precedence problem# default_scope order("created_at DESC")

  # Returns the hash of assigned permissions #1504# TODO return directly the integer (bits & mask)
  def actions
    h = {}
    ACTIONS.each_with_index do |a, i|
      j = 2 ** i
      next if (j & action_mask).zero?
      h[a] = !(j & action_bits).zero? 
    end
    h
  end

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
    if action_mask.zero? and not media_resource_id.nil? # TODO validation ???
      destroy
    else
      save
    end
  end

##################################################
  class << self

    # OPTIMIZE could be the subject argument a Group ?? or it's always a User ??
    # is a subject authorized to perform action on a resource?
    # returns true or false
    def authorized?(subject, action, resource)
      # TODO default manage permission for associated user (owner) ?? 
      #return true if action == :manage and subject == resource.user
      
      # force to boolean
      !!merged_actions(subject, resource)[action]
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
      p = where(:subject_id => nil, :subject_type => nil, :media_resource_id => nil).first
      p ? p.actions : {} #1504#
    end
  
    def resource_default(resource)
      cached_permissions_by(resource).detect {|x| x.subject.nil? }
    end

    def resource_default_actions(resource)
      p = resource_default(resource)
      system_default_actions.merge(p ? p.actions : {}) #1504#
    end
 
    # TODO remove
    def cached_permissions_by(resource)
      p = resource.permissions.all
      p << resource.permissions.build(:subject => nil) unless p.any? {|x| x.subject.nil?} #2904# OPTIMIZE
      p
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
            ACTIONS.each do |key|
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

    def assign_manage_to(subject, resource, recursive = false)
      @subject = subject
      @i = 2 ** ACTIONS.index(:manage)
      
      def assign_for(resource)
        resource.permissions.where(" #{SQLHelper.bitwise_is('action_bits',@i)} AND #{SQLHelper.bitwise_is('action_mask',@i)}").first.set_actions({:manage => false})
        h = {:view => true, :edit => true, :manage => true}
        h[:hi_res] = true if resource.is_a?(MediaEntry)
        resource.permissions.find_or_create_by_subject_type_and_subject_id(@subject.class.base_class.name, @subject.id).set_actions(h)
      end
      
      assign_for(resource) # TODO only in case of MediaEntry or MediaSet ??  
      
      resource.media_entries.each do |me|
        assign_for(me)
      end if resource.is_a?(MediaSet) and recursive
    end

  end


end

