class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    Constants::Actions.each do |action|

        actionable_by_userpermission=  actionable_media_resources_users_by_userpermission action
        
        actionable_disallowed_by_userpermission=  actionable_media_resources_users_disallowed_by_userpermission action

        actionable_by_grouppermission= actionable_media_resources_users_by_grouppermission action

        actionable_by_gp_not_denied_by_up= actionable_by_grouppermission
          .where(" (media_resource_id,user_id)  NOT IN (#{actionable_disallowed_by_userpermission.to_sql}) ")

        actionable_by_publicpermission=  actionable_media_resources_users_by_publicpermission action
        
        actionable_by_ownership= actionable_media_resources_users_by_ownership action

        actionable_users= <<-SQL 
          ( #{actionable_by_userpermission.to_sql} )
            UNION  ( #{actionable_by_gp_not_denied_by_up.to_sql} )
            UNION ( #{actionable_by_publicpermission.to_sql} )
            UNION ( #{actionable_by_ownership.to_sql} )
        SQL

        create_view "#{action}able_media_resources_users",actionable_users

#        {media_entry: MediaEntry, media_set: MediaSet}.each do |singular,model|
#          sql= <<-SQL 
#              SELECT media_resources.id as #{singular.to_s}_id, #{action}able_media_resources_users.user_id as user_id 
#                FROM media_resources
#                INNER JOIN #{action}able_media_resources_users 
#                  ON #{action}able_media_resources_users.media_resource_id = media_resources.id
#                WHERE media_resources.type = '#{model.name}'
#          SQL
#          create_view "#{action}able_#{singular.to_s.pluralize}_users", sql
#        end


    end

  end

  def down

    Constants::Actions.each do |action|
#      {media_entry: MediaEntry, media_set: MediaSet}.each do |singular,model|
#        drop_view "#{action}able_#{singular.to_s.pluralize}_users"
#      end
      drop_view "#{action}able_media_resources_users"
    end

  end

end
