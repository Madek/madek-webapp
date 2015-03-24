class CreateAdminUsers < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :admin_users, id: :uuid do |t|

      t.uuid :user_id, null: false
      t.index :user_id, unique: true

      t.timestamps null: false
    end

    add_foreign_key :admin_users, :users, on_delete: :cascade

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :admin_users
      end

    end
  end

end
