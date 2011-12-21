
module Permissions
  extend self 

  class << self

    def authorized?(subject, action, resource)
      if resource.owner == user
        true
      elsif action == :view && resource.perm_public_may_view 
        true
      elsif userpermission_disallows action, mediaresource, user
        false
      elsif userpermission_allows action, mediaresource, user
        true
      elsif grouppermissions_allows action, mediaresource, user
        true
      else
        false
      end 
    end

    def userpermission_disallows action, resource, user
        resource.class.joins(:userpermissions => :user) \
          .where("#{resource.class.table_name}.id = #{resource.id}") \
          .where("users.id = #{user.id}") \
          .where("userpermissions.maynot_#{action} = true")
          .first
    end

    def userpermission_allows action, resource, user
        resource.class.joins(:userpermissions => :user) \
          .where("#{resource.class.table_name}.id = #{resource.id}") \
          .where("users.id = #{user.id}") \
          .where("userpermissions.may_#{action} = true")
          .first
    end

    def grouppermission_allows action, resource, user
      resource.class.joins(:grouppermissions => {:group => :users}) \
        .where("#{resource.class.table_name}.id = #{resource.id}") \
        .where("users.id = #{user.id}") \
        .where("grouppermissions.may_#{action} = true") \
        .first
    end

 

#    def can_view?(mediaresource, user)
#
#      return true if mediaresource.owner == user
#
#      return true if mediaresource.perm_public_may_view 
#
#      return false if mediaresourceuserpermission_disallows :view, mediaresource, user
#
#      return true if mediaresourceuserpermission_allows :view, mediaresource, user
#
#      return true if mediaresourcegrouppermission_allows :view, mediaresource, user
#
#      false
#
#    end
#
#
#    def mediaresourceuserpermission_disallows what, mediaresource, user 
#      (Mediaresourceuserpermission.count_by_sql %Q@ 
#        SELECT count(*) from mediaresourceuserpermissions 
#          WHERE mediaresource_id=#{mediaresource.id} 
#            AND user_id=#{user.id} 
#            AND maynot_#{what.to_s} = true; 
#       @) > 0
#    end
#
#    def mediaresourceuserpermission_allows what, mediaresource, user 
#      (Mediaresourceuserpermission.count_by_sql %Q@ 
#        SELECT count(*) from mediaresourceuserpermissions 
#          WHERE mediaresource_id=#{mediaresource.id} 
#            AND user_id=#{user.id} 
#            AND may_#{what.to_s} = true; 
#       @) > 0
#    end
#
#    def mediaresourcegrouppermission_allows what, mediaresource, user
#      (Mediaresourcegrouppermission.count_by_sql %Q@ 
#      SELECT count(*) from mediaresourcegrouppermissions, users, usergroups_users 
#        WHERE users.id = usergroups_users.user_id 
#          AND mediaresourcegrouppermissions.usergroup_id = usergroups_users.usergroup_id
#          AND mediaresourcegrouppermissions.mediaresource_id = #{mediaresource.id}
#          AND users.id = #{user.id}
#          AND may_#{what.to_s} = true
#          LIMIT 1; 
#          @) > 0
#    end

  end

end
