class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    Constants::Actions.each do |action|

        actionable_by_userpermission= \
          Userpermission.select("media_resource_id,user_id").where(action => true)
        
        actionable_disallowed_by_userpermission=  \
          Userpermission.select("media_resource_id,user_id").where(action => false)

        actionable_by_grouppermission= \
          Grouppermission.joins(:group => :users) \
          .select("media_resource_id,user_id").where(action => true)


        actionable_by_gp_not_denied_by_up= actionable_by_grouppermission
          .where(" (media_resource_id,user_id)  NOT IN (#{actionable_disallowed_by_userpermission.to_sql}) ")

        actionable_by_publicpermission= 
          User.joins("CROSS JOIN media_resources") \
          .select("media_resources.id as media_resource_id, users.id as user_id") \
          .where("media_resources.#{action}" => true )
        
        actionable_by_ownership=  
          MediaResource.select("media_resources.id as media_resource_id, user_id as user_id") 

        actionable_users= <<-SQL 
          SELECT * FROM  #{action}able_media_resources_by_userpermission
            UNION SELECT * from #{action}able_media_resources_by_gp_not_denied_by_up
            UNION SELECT * from #{action}able_media_resources_by_publicpermission
            UNION SELECT * from #{action}able_media_resources_by_ownership;
        SQL

        create_view "#{action}able_media_resources_by_userpermission", actionable_by_userpermission
        create_view "#{action}able_media_resources_disallowed_by_userpermission", actionable_disallowed_by_userpermission
        create_view "#{action}able_media_resources_by_grouppermission", actionable_by_grouppermission
        create_view "#{action}able_media_resources_by_gp_not_denied_by_up",actionable_by_gp_not_denied_by_up
        create_view "#{action}able_media_resources_by_publicpermission", actionable_by_publicpermission
        create_view "#{action}able_media_resources_by_ownership",actionable_by_ownership
        create_view "#{action}able_media_resources_users",actionable_users

        {media_entry: MediaEntry, media_set: MediaSet}.each do |singular,model|
          sql= <<-SQL 
              SELECT media_resources.id as #{singular.to_s}_id, #{action}able_media_resources_users.user_id as user_id 
                FROM media_resources
                INNER JOIN #{action}able_media_resources_users 
                  ON #{action}able_media_resources_users.media_resource_id = media_resources.id
                WHERE media_resources.type = '#{model.name}'
          SQL
          create_view "#{action}able_#{singular.to_s.pluralize}_users", sql
        end


    end

  end

  def down

    Constants::Actions.each do |action|
      {media_entry: MediaEntry, media_set: MediaSet}.each do |singular,model|
        drop_view "#{action}able_#{singular.to_s.pluralize}_users"
      end
      drop_view "#{action}able_media_resources_users"
      drop_view "#{action}able_media_resources_by_ownership"
      drop_view "#{action}able_media_resources_by_publicpermission"
      drop_view "#{action}able_media_resources_by_gp_not_denied_by_up"
      drop_view "#{action}able_media_resources_by_grouppermission"
      drop_view "#{action}able_media_resources_disallowed_by_userpermission"
      drop_view "#{action}able_media_resources_by_userpermission"
    end

  end

end
