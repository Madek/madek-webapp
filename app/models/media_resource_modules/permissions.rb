# -*- encoding : utf-8 -*-

module MediaResourceModules
  module Permissions

    def self.included(base)

      base.class_eval do

        extend(ClassMethods) # look way below

        has_many :userpermissions, :dependent => :destroy do
          def allows(user, action)
            where(:user_id => user, action => true).first
          end
          def disallows(user, action)
            where(:user_id => user, action => false).first
          end
        end
        
        has_many :grouppermissions, :dependent => :destroy do
          def allows(user, action)
            joins(:group => :users).where(action => true, :groups_users => {:user_id => user}).first
          end
        end

      end
    end


    ### instance methods 

    def users_permitted_to_act(action)
      # do not optimize away this query as resource.user can be null
      owner_id = User.select("users.id").joins(:media_resources).where("media_resources.id" => id)
      user_ids_by_userpermission= Userpermission.select("user_id").where("media_resource_id" => id).where("userpermissions.#{action}" => true)
      user_ids_dissallowed_by_userpermission = Userpermission.select("user_id").where("media_resource_id" => id).where("userpermissions.#{action}" => false)
      user_ids_by_grouppermission_but_not_dissallowed= Grouppermission.select("groups_users.user_id as user_id").joins(:group).joins("INNER JOIN groups_users ON groups_users.group_id = groups.id").where("media_resource_id" => id).where("grouppermissions.#{action}" => true).where(" user_id NOT IN ( #{user_ids_dissallowed_by_userpermission.to_sql} )")
      user_ids_by_publicpermission= User.select("users.id").joins("CROSS JOIN media_resources").where("media_resources.#{action}" => true)

      User.where " users.id IN (
            #{owner_id.to_sql}
          UNION
            #{user_ids_by_userpermission.to_sql}
          UNION
            #{user_ids_by_grouppermission_but_not_dissallowed.to_sql}
          UNION
            #{user_ids_by_publicpermission.to_sql})"
    end

    def managers
      users_permitted_to_act :manage
    end

    def is_public?
      view?
    end

    def is_private?(user)
      (user_id == user.id and
        not is_public? and
        not userpermissions.where(:view => true).where(["user_id != ?", user]).exists? and
        not grouppermissions.where(:view => true).exists?)
    end



    #############################################
  
    module ClassMethods 

      def userpermissions_disallowed user,action
        Userpermission.where(action => false, :user_id => user)
      end

      def grouppermissions_not_disallowed user,action
        Grouppermission 
          .where(action => true)
          .joins("INNER JOIN groups_users ON groups_users.group_id = grouppermissions.group_id ")
          .where("groups_users.user_id = #{user.id}")
          .where <<-SQL  
              media_resource_id NOT IN ( 
                  #{userpermissions_disallowed(user, action).select("media_resource_id").to_sql} 
              )
              SQL
      end

      ##############################

      # TODO: try to dry user and group to subject
      def accessible_by_user(user, action = :view)
        action = action.to_sym

        unless user.try(:id)
          where(action => true)
        else
          resource_ids_by_userpermission = Userpermission.select("media_resource_id").where(action => true, :user_id => user)
          resource_ids_by_ownership_or_public_permission = MediaResource.select("media_resources.id").where(["media_resources.user_id = ? OR media_resources.#{action} = ?", user, true])

          where " media_resources.id IN  (
          #{resource_ids_by_userpermission.to_sql} 
            UNION
          #{grouppermissions_not_disallowed(user,action).select("media_resource_id").to_sql} 
            UNION
          #{resource_ids_by_ownership_or_public_permission.to_sql}
                  )" 
        end
      end
      
      def accessible_by_group(group, action = :view)
        action = action.to_sym

        # TODO inner join sql
        resource_ids_by_grouppermission = Grouppermission.select("media_resource_id").where(action => true, :group_id => group)
        where " media_resources.id IN  ( #{resource_ids_by_grouppermission.to_sql} )" 
      end

      ##############################

      def where_permission_presets_and_user presets, user 

          # BEGIN BY_GROUPPERMISSION
          by_grouppermission = 
            presets.reduce(" SELECT NULL \n") do |grouppermission_query,preset|

              # BEGIN EXCEPT clause for preselected grouppermissions
              #  all those media entries the user is allowed for the current preset by grouppermission but denied by some userpermission
              #  we will then use except_denied_db_adapter_dependent further below
              preset_true_actions = Constants::Actions.select{|action| preset[action]}
              denied_mediaresource_ids = 
                preset_true_actions.reduce("(SELECT NULL)") do |denied_query, action|
                  media_resource_ids_deniedby_userpermission =
                    Userpermission.where(action => false).where(user_id: user).joins(:media_resource).select("media_resources.id")
                  denied_query + "UNION  #{media_resource_ids_deniedby_userpermission.to_sql} "
                end
              # END EXCEPT
              
              # BEGIN GROUPPERMISSIONS_PRESET here is where the actual query based on the preset gets formed
              grouppermissions_with_actions = 
                Constants::Actions.reduce(Grouppermission) do |up,action|
                  up.where(action => preset[action])
                end

              media_resource_ids_by_grouppermissions =
                grouppermissions_with_actions
                  .joins(group: :users)
                  .where("users.id = ?", user.id)
                  .joins(:media_resource)
                  .select("media_resources.id as media_resource_id")

                  if SQLHelper.adapter_is_postgresql? 
                    "#{grouppermission_query} UNION  (( #{media_resource_ids_by_grouppermissions.to_sql} ) EXCEPT (#{denied_mediaresource_ids}))  \n"
                  elsif SQLHelper.adapter_is_mysql?
                    "#{grouppermission_query} UNION  #{media_resource_ids_by_grouppermissions.to_sql} \n"
                  else
                    raise "adapter not supported"
                  end
              #END GROUPPERMISSIONS_PRESET
            end 
          # END BY_GROUPPERMISSION

          # BEGIN BY_USERPERMISSION
          by_userpermission =
            presets.reduce(" SELECT NULL \n") do |up_query,preset|
            userpermission_by_action =
              Constants::Actions.reduce(Userpermission) do |up,action|
                up.where(action => preset[action])
              end
             media_resource_ids_by_userpermission =
               userpermission_by_action.where(user_id: user).joins(:media_resource).select("media_resources.id as media_resource_id")
            up_query + "UNION  #{media_resource_ids_by_userpermission.to_sql}  \n"
            end 
          # END BY_USERPERMISSION

          # now put user and grouppermissions together in chainable query
          where "id in (#{by_grouppermission} UNION #{by_userpermission})" 

      end

    end

  end

end


