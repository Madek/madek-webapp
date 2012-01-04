class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    [Media::Set,MediaEntry].each do |model|

      tname = model.table_name

      select_ms = "SELECT media_sets.id as media_set_id, users.id as user_id FROM"

      viewable_by_userpermission= \
        Media::Set.joins(:userpermissions => :user) \
          .where("userpermissions.may_view = true").to_sql \
          .gsub /SELECT.*FROM/, select_ms

      non_viewable_by_userpermission= \
        Media::Set.joins(:userpermissions => :user) \
          .where("userpermissions.may_view = false").to_sql \
          .gsub /SELECT.*FROM/, select_ms

      viewable_by_grouppermission= \
        Media::Set.joins(:grouppermissions => {:group => :users}) \
        .where("grouppermissions.may_view = true").to_sql \
        .gsub /SELECT.*FROM/, select_ms

      viewable_by_gp_not_denied_by_up=  <<-SQL
        SELECT * from viewable_#{tname}_by_grouppermission
        WHERE (media_set_id,user_id) 
          NOT IN (SELECT media_set_id,user_id from non_viewable_#{tname}_by_userpermission);
      SQL

      viewable_by_publicpermission= <<-SQL
      #{select_ms} media_sets
          CROSS JOIN users 
          WHERE media_sets.perm_public_may_view = true;
      SQL

      viewable_by_ownership= <<-SQL
      SELECT media_sets.id as media_sets_id, owner_id as user_id from  media_sets;
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
    [Media::Set,MediaEntry].each do |model|

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
