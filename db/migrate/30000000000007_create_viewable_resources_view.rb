class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    [Media::Set,MediaEntry,MediaResource].each do |model|

      tname = model.table_name
      fkey_name = (ActiveSupport::Inflector.singularize tname)+ "_id"

      select_ms = "SELECT #{tname}.id as #{fkey_name}, users.id as user_id FROM"

      viewable_by_userpermission= \
        model.joins(:userpermissions => :user) \
          .where("userpermissions.may_view = true").to_sql \
          .gsub /SELECT.*FROM/, select_ms

      non_viewable_by_userpermission= \
        model.joins(:userpermissions => :user) \
          .where("userpermissions.may_view = false").to_sql \
          .gsub /SELECT.*FROM/, select_ms

      viewable_by_grouppermission= \
        model.joins(:grouppermissions => {:group => :users}) \
        .where("grouppermissions.may_view = true").to_sql \
        .gsub /SELECT.*FROM/, select_ms

      viewable_by_gp_not_denied_by_up=  <<-SQL
        SELECT * from viewable_#{tname}_by_grouppermission
        WHERE (#{fkey_name},user_id) 
          NOT IN (SELECT #{fkey_name},user_id from non_viewable_#{tname}_by_userpermission);
      SQL

      viewable_by_publicpermission= <<-SQL
      #{select_ms} #{tname}
          CROSS JOIN users 
          WHERE #{tname}.perm_public_may_view = true;
      SQL

      viewable_by_ownership= <<-SQL
        SELECT #{tname}.id as #{fkey_name}, owner_id as user_id from #{tname};
      SQL

      viewable_users= <<-SQL 
      SELECT * FROM  viewable_#{tname}_by_userpermission
        UNION SELECT * from viewable_#{tname}_by_gp_not_denied_by_up
        UNION SELECT * from viewable_#{tname}_by_publicpermission
        UNION SELECT * from viewable_#{tname}_by_ownership;
      SQL

      create_view "viewable_#{tname}_by_userpermission", viewable_by_userpermission
      create_view "non_viewable_#{tname}_by_userpermission", non_viewable_by_userpermission
      create_view "viewable_#{tname}_by_grouppermission", viewable_by_grouppermission
      create_view "viewable_#{tname}_by_gp_not_denied_by_up", viewable_by_gp_not_denied_by_up
      create_view "viewable_#{tname}_by_publicpermission", viewable_by_publicpermission
      create_view "viewable_#{tname}_by_ownership", viewable_by_ownership
      create_view "viewable_#{tname}_users", viewable_users

    end


  end

  def down
    [Media::Set,MediaEntry,MediaResource].each do |model|

      tname = model.table_name

      drop_view "viewable_#{tname}_users"
      drop_view "viewable_#{tname}_by_ownership"
      drop_view "viewable_#{tname}_by_publicpermission"
      drop_view "viewable_#{tname}_by_gp_not_denied_by_up"
      drop_view "viewable_#{tname}_by_grouppermission"
      drop_view "non_viewable_#{tname}_by_userpermission"
      drop_view "viewable_#{tname}_by_userpermission"

    end
  end
end
