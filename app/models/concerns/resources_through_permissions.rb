module Concerns
  module ResourcesThroughPermissions
    extend ActiveSupport::Concern

    module ClassMethods

      def userpermission_query(user,action)
        Userpermission \
          .where("userpermissions.media_resource_id = media_resources.id") \
          .where(action => true).where(user_id: user)
      end

      def grouppermission_by_user_query(user,action)
        Grouppermission.joins(group: :users) \
          .where("grouppermissions.media_resource_id = media_resources.id") \
          .where(action => true).where("users.id = ?", user.id)
      end

      def grouppermission_by_group_query(group,action)
        Grouppermission \
          .where("grouppermissions.media_resource_id = media_resources.id") \
          .where(action => true).where(group_id: group)
      end


      def accessible_to_public(action)
          if action.to_sym == :manage
            where('FALSE') 
          else
            where("media_resources.#{action.to_s} = true")
          end
      end

      def accessible_by_user(user,action)
        if user.nil? or user.is_guest?
          accessible_to_public(action)
        elsif user.act_as_uberadmin  
          where("TRUE")
        else
          accessible_by_signedin_user(user,action)
        end
      end

      def accessible_by_signedin_user(user,action)
        where <<-SQL 
                media_resources.user_id = #{user.id}
                OR
                media_resources.#{action.to_s} = true
                OR
                EXISTS ( #{userpermission_query(user,action).select("'true'").to_sql} ) 
                OR
                EXISTS ( #{grouppermission_by_user_query(user,action).select("'true'").to_sql} ) 
                SQL
      end


      def accessible_by_group(group, action)
        where(" EXISTS ( #{grouppermission_by_group_query(group,action).to_sql } ) ")
      end

      # not the owner but has userpermission or grouppermission
      def entrusted_to_user(user, action)
        where("media_resources.user_id <> ?",user)\
        .where <<-SQL 
                EXISTS ( #{userpermission_query(user,action).select("'true'").to_sql} ) 
                OR
                EXISTS ( #{grouppermission_by_user_query(user,action).select("'true'").to_sql} ) 
                SQL
      end

    end
  end
end
