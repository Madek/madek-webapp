class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up
      
    SELECT_MS = "SELECT media_sets.id as media_set_id, users.id as user_id FROM"

    viewable_mediasets_by_userpermission= \
      Media::Set.joins(:media_sets_userpermissions_joins => {:userpermission => :user}) \
        .where("userpermissions.may_view = true").to_sql \
        .gsub /SELECT.*FROM/, SELECT_MS

    non_viewable_mediasets_by_userpermission= \
      Media::Set.joins(:media_sets_userpermissions_joins => {:userpermission => :user}) \
        .where("userpermissions.may_view = false").to_sql \
        .gsub /SELECT.*FROM/, SELECT_MS


    viewable_mediasets_by_usergrouppermission= \
      Media::Set.joins(:media_sets_grouppermissions_joins => {:grouppermission => {:group => :users}}) \
        .where("grouppermissions.may_view = true").to_sql \
        .gsub /SELECT.*FROM/, SELECT_MS


    viewable_mediasets_by_gp_not_denied_by_up=  <<-SQL
        SELECT * from viewable_mediasets_by_gp_not_denied_by_up
        WHERE (media_set_id,user_id) NOT IN (SELECT media_set_id,user_id from non_viewable_mediasets_by_userpermission);
      SQL

    viewable_mediasets_by_publicpermission= <<-SQL
        #{SELECT_MS} media_sets
          CROSS JOIN users 
          WHERE media_sets.perm_public_may_view = true;
      SQL

    viewable_mediasets_by_ownership= <<-SQL
      SELECT media_sets.id as media_sets_id, owner_id as user_id from  media_sets;
    SQL

      CREATE VIEW viewable_mediaresources_users AS
        SELECT * FROM  viewable_mediaresources_by_userpermission
          UNION SELECT * from viewable_mediaresources_by_gp_without_denied_by_up
          UNION SELECT * from viewable_mediasets_by_publicpermission
          UNION SELECT * from viewable_mediaresources_by_ownwership;


    create_view :viewable_mediasets_by_userpermission, viewable_mediasets_by_userpermission
    create_view :non_viewable_mediasets_by_userpermission, non_viewable_mediasets_by_userpermission
    create_view :viewable_mediasets_by_usergrouppermission, viewable_mediasets_by_usergrouppermission
    create_view :viewable_mediasets_by_publicpermission, viewable_mediasets_by_publicpermission
    create_view :viewable_mediasets_by_ownership, viewable_mediasets_by_ownership



  end

  def down

    drop_view :viewable_mediasets_by_userpermission
    drop_view :viewable_mediasets_by_usergrouppermission
    drop_view :non_viewable_mediasets_by_userpermission


  end
end
