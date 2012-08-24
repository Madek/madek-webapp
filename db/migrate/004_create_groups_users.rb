# -*- encoding : utf-8 -*-
class CreateGroupsUsers < ActiveRecord::Migration

  def up

    create_table  :groups_users, id: false do |t|
      t.integer :group_id, null: false
      t.integer :user_id, null: false
    end

    add_index :groups_users, [:user_id,:group_id], unique: true
    add_index :groups_users, [:group_id,:user_id]

    add_foreign_key :groups_users, :users, dependent: :delete
    add_foreign_key :groups_users, :groups, dependent: :delete

  end

  def down
    drop_table :groups_users
  end

end
