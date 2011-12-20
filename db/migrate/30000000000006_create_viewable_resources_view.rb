class CreateViewableResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up

    viewable_mediasets_by_userpermission= \
      Media::Set.joins(:media_sets_userpermissions_joins => {:userpermission => :user}) \
        .where("userpermissions.may_view = true").to_sql \
        .gsub /SELECT.*FROM/, "SELECT media_sets.id as media_set_id, users.id as user_id FROM"

    create_view :viewable_mediasets_by_userpermission, viewable_mediasets_by_userpermission

  end

  def down

    drop_view :viewable_mediasets_by_userpermission

  end
end
