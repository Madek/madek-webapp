module Concerns
  module ResourcesThroughPermissions
    extend ActiveSupport::Concern
    module ::ClassMethods

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
      
      def accessible_by_user(user, action = :view)
        action = (action || :view).to_sym

        if user.nil? or user.is_guest?
          if action == :manage
            where('false') 
          else
            where("media_resources.#{action.to_s} = true")
          end
        else
          resource_ids_by_userpermission = Userpermission.select("media_resource_id").where(action => true, :user_id => user)
          subquery = if action == :manage
            resource_ids_by_ownership = MediaResource.select("media_resources.id").where(["media_resources.user_id = ?", user])
            "#{resource_ids_by_userpermission.to_sql}
              UNION
            #{resource_ids_by_ownership.to_sql}"
          else
            resource_ids_by_ownership_or_public_permission = MediaResource.select("media_resources.id").where(["media_resources.user_id = ? OR media_resources.#{action} = ?", user, true])
            "#{resource_ids_by_userpermission.to_sql}
              UNION
            #{grouppermissions_not_disallowed(user,action).select("media_resource_id").to_sql}
              UNION
            #{resource_ids_by_ownership_or_public_permission.to_sql}"
          end
          where("media_resources.id IN (#{subquery})")
        end
      end

      def accessible_by_group(group, action = :view)
        action = (action || :view).to_sym
        return where("0=1") if action == :manage

        # TODO inner join sql
        resource_ids_by_grouppermission = Grouppermission.select("media_resource_id").where(action => true, :group_id => group)
        where(:id => resource_ids_by_grouppermission)
      end
      
      # TODO merge to accessible_by_user with additional argument
      def entrusted_to_user(user, action = :view)
        action = (action || :view).to_sym
        resource_ids_by_userpermission = Userpermission.select("media_resource_id").where(action => true, :user_id => user)
        subquery = if action == :manage
          resource_ids_by_userpermission.to_sql
        else
          "#{resource_ids_by_userpermission.to_sql}
            UNION
          #{grouppermissions_not_disallowed(user,action).select("media_resource_id").to_sql}"
        end
        where("media_resources.id IN (#{subquery})").where(arel_table[:user_id].not_eq user.id)
      end



    end
  end
end
