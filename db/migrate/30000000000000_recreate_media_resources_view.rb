class RecreateMediaResourcesView < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up
    drop_view "media_resources"

    create_table :media_resources do |t| 

      t.integer :owner_id, :null => false

      Actions.each do |action|
        t.boolean "may_#{action}", :default => false
      end

    end

    add_index :media_resources, :owner_id

  end

  def down

    drop_table "media_resources"

    create_view "media_resources", <<-SQL
      (SELECT id, type, user_id, NULL AS upload_session_id, NULL AS media_file_id, created_at, updated_at FROM media_sets)
      UNION 
      (SELECT me.id, 'MediaEntry' AS type, us.user_id, upload_session_id, media_file_id, me.created_at, me.updated_at
       FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = true);
    SQL

  end

end
