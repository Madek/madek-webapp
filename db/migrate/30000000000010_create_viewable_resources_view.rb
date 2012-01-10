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

        create_view "#{action}able_media_resources_by_userpermission", actionable_by_userpermission
        create_view "#{action}able_disallowd_media_resources_by_userpermission", actionable_disallowed_by_userpermission
        create_view "#{action}able_media_resources_by_grouppermissions", actionable_by_grouppermission

    end

  end

  def down

    Constants::Actions.each do |action|

      drop_view "#{action}able_disallowd_media_resources_by_userpermission"
      drop_view "#{action}able_media_resources_by_userpermission"

    end

  end


=begin
    Constants::Actions.each do |action|
      [MediaResource].each do |model|

        tname = model.table_name
        fkey_name = (ActiveSupport::Inflector.singularize tname)+ "_id"

        select_ms = "SELECT #{tname}.id as #{fkey_name}, users.id as user_id FROM"

        actionable_by_userpermission= \
          model.joins(:userpermissions => :user) \
          .where("userpermissions.may_view = true").to_sql \
          .gsub /SELECT.*FROM/, select_ms

        actionable_disallowed_by_userpermission= \
          model.joins(:userpermissions => :user) \
          .where("userpermissions.may_view = false").to_sql \
          .gsub /SELECT.*FROM/, select_ms

        actionable_by_grouppermission= \
          model.joins(:grouppermissions => {:group => :users}) \
          .where("grouppermissions.may_view = true").to_sql \
          .gsub /SELECT.*FROM/, select_ms

        actionable_by_gp_not_denied_by_up=  <<-SQL
          SELECT * from #{action}able_#{tname}_by_grouppermission
          WHERE (#{fkey_name},user_id) 
            NOT IN (SELECT #{fkey_name},user_id from #{action}able_#{tname}_disallowed_by_userpermission);
        SQL

        actionable_by_publicpermission= <<-SQL
          #{select_ms} #{tname}
            CROSS JOIN users 
            WHERE #{tname}.perm_public_may_view = true;
        SQL

        actionable_by_ownership= <<-SQL
          SELECT #{tname}.id as #{fkey_name}, owner_id as user_id from #{tname};
        SQL

        actionable_users= <<-SQL 
          SELECT * FROM  #{action}able_#{tname}_by_userpermission
            UNION SELECT * from #{action}able_#{tname}_by_gp_not_denied_by_up
            UNION SELECT * from #{action}able_#{tname}_by_publicpermission
            UNION SELECT * from #{action}able_#{tname}_by_ownership;
        SQL

        create_view "#{action}able_#{tname}_by_userpermission",actionable_by_userpermission
        create_view "#{action}able_#{tname}_disallowed_by_userpermission",actionable_disallowed_by_userpermission
        create_view "#{action}able_#{tname}_by_grouppermission",actionable_by_grouppermission
        create_view "#{action}able_#{tname}_by_gp_not_denied_by_up",actionable_by_gp_not_denied_by_up
        create_view "#{action}able_#{tname}_by_publicpermission",actionable_by_publicpermission
        create_view "#{action}able_#{tname}_by_ownership",actionable_by_ownership
        create_view "#{action}able_#{tname}_users",actionable_users

      end
    end

=end



=begin
    Constants::Actions.each do |action|
      [MediaResource].each do |model|

        tname = model.table_name

        drop_view "#{action}able_#{tname}_users"
        drop_view "#{action}able_#{tname}_by_ownership"
        drop_view "#{action}able_#{tname}_by_publicpermission"
        drop_view "#{action}able_#{tname}_by_gp_not_denied_by_up"
        drop_view "#{action}able_#{tname}_by_grouppermission"
        drop_view "#{action}able_#{tname}_disallowed_by_userpermission"
        drop_view "#{action}able_#{tname}_by_userpermission"

      end
    end
=end

end
