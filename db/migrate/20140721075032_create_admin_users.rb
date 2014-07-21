class CreateAdminUsers < ActiveRecord::Migration
  def up
    create_table :admin_users, id: false do |t|
      t.uuid :id, default: 'uuid_generate_v4()'
      t.uuid :user_id, null: false

      t.index :user_id
    end
    execute 'ALTER TABLE admin_users ADD PRIMARY KEY (id)'
  end

  def down
    drop_table :admin_users
  end
end
