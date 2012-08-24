class CreateEditSessions < ActiveRecord::Migration

  def up
    create_table :edit_sessions do |t|
      t.integer :user_id, null: false
      t.integer :media_resource_id, null: false
      t.timestamps
    end
    add_index :edit_sessions, :media_resource_id
    add_index :edit_sessions, :user_id
    add_foreign_key :edit_sessions, :media_resources, dependent: :delete
    add_foreign_key :edit_sessions, :users, dependent: :delete

  end

  def down
    drop_table :edit_sessions
  end
end
