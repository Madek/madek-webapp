class DropUploadSessions < ActiveRecord::Migration
  def up
    remove_column :media_resources, :upload_session_id
 
    drop_table :upload_sessions
  end

  def down
  end
end
