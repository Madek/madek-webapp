class RecreateMediaResourcesView < ActiveRecord::Migration
  include MigrationHelpers

  def up
    drop_view "media_resources"

    create_view "media_resources", <<-SQL
      (SELECT id, type, owner_id, user_id, NULL AS upload_session_id, NULL AS media_file_id, perm_public_may_view, created_at, updated_at FROM media_sets)
      UNION 
      (SELECT me.id, 'MediaEntry' AS type, us.user_id, owner_id, upload_session_id, media_file_id, perm_public_may_view, me.created_at, me.updated_at
       FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = true);
    SQL

  end

  def down

    drop_view "media_resources"

    create_view "media_resources", <<-SQL
      (SELECT id, type, user_id, NULL AS upload_session_id, NULL AS media_file_id, created_at, updated_at FROM media_sets)
      UNION 
      (SELECT me.id, 'MediaEntry' AS type, us.user_id, upload_session_id, media_file_id, me.created_at, me.updated_at
       FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = true);
    SQL

  end

end
