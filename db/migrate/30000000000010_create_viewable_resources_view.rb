class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    Constants::Actions.each do |action|

        select_ms = "SELECT media_resources.id as media_resource_id, users.id as user_id FROM"

        actionable_by_userpermission= \
          Userpermission.joins(:user,:permissionset,:media_resource) \
          .where("permissionsets.#{action} = true") \
          .to_sql.gsub /SELECT.*FROM/, select_ms

        actionable_disallowed_by_userpermission= \
          Userpermission.joins(:user,:permissionset,:media_resource) \
            .where("permissionsets.#{action} = false") \
           .to_sql.gsub /SELECT.*FROM/, select_ms

        actionable_by_grouppermission= \
          Grouppermission.joins(:permissionset,:media_resource,:group => :users) \
            .where("permissionsets.#{action} = true") \
            .to_sql.gsub /SELECT.*FROM/, select_ms

        actionable_by_gp_not_denied_by_up=  <<-SQL
          SELECT * from #{action}able_media_resources_by_grouppermission
          WHERE (media_resource_id,user_id) 
            NOT IN (SELECT media_resource_id,user_id from #{action}able_media_resources_disallowed_by_userpermission);
        SQL

        actionable_by_publicpermission=
          MediaResource.joins(:permissionset).joins("CROSS JOIN users") \
            .where("permissionsets.#{action} = true") \
            .to_sql.gsub /SELECT.*FROM/, select_ms

        actionable_by_ownership= "SELECT media_resources.id as media_resource_id, owner_id as user_id from media_resources; "

        
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


        [Media::Set,MediaEntry].each do |model|
          table_name = model.table_name
          sql= <<-SQL 
            SELECT #{table_name}.id as #{ref_id model}, #{action}able_media_resources_users.user_id as user_id 
              FROM #{table_name}
              INNER JOIN #{action}able_media_resources_users 
                ON #{action}able_media_resources_users.media_resource_id = #{table_name}.media_resource_id;
          SQL
          create_view "#{action}able_#{table_name}_users", sql
        end

    end

  end

  def down

    [Media::Set,MediaEntry].each do |model|
      table_name = model.table_name
      drop_view "#{action}able_#{table_name}_users"
    end

    Constants::Actions.each do |action|
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
