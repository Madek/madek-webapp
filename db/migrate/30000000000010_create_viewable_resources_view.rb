class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    Constants::Actions.each do |action|

        actionable_by_userpermission= <<-SQL
          SELECT media_resource_id as media_resource_id, user_id as user_id 
            FROM userpermissions 
            JOIN permissionsets ON permissionsets.id = userpermissions.permissionset_id
            WHERE permissionsets.#{action} = true;
        SQL

        actionable_disallowed_by_userpermission=  \
          actionable_by_userpermission.gsub /true/, "false"
        
        actionable_by_grouppermission= <<-SQL
          SELECT media_resource_id as media_resource_id, user_id as user_id 
            FROM grouppermissions
              JOIN permissionsets ON permissionsets.id = grouppermissions.permissionset_id
              JOIN groups_users ON groups_users.group_id = grouppermissions.group_id
            WHERE permissionsets.#{action} = true; 
          SQL

        actionable_by_gp_not_denied_by_up=  <<-SQL
          SELECT * from #{action}able_media_resources_by_grouppermission
          WHERE (media_resource_id,user_id) 
            NOT IN (SELECT media_resource_id,user_id from #{action}able_media_resources_disallowed_by_userpermission);
        SQL

        actionable_by_publicpermission= <<-SQL
          SELECT media_resources.id as media_resource_id, users.id as user_id 
            FROM media_resources
            INNER JOIN permissionsets ON permissionsets.id = media_resources.permissionset_id
            CROSS JOIN users
            WHERE permissionsets.#{action} = true;
          SQL

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


        [MediaSet,MediaEntry].each do |model|
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

    Constants::Actions.each do |action|
      [MediaSet,MediaEntry].each do |model|
        table_name = model.table_name
        drop_view "#{action}able_#{table_name}_users"
      end
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
