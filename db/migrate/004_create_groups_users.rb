# -*- encoding : utf-8 -*-
class CreateGroupsUsers < ActiveRecord::Migration

  def change
    create_table :groups_users, id: false do |t|
      t.uuid :group_id, null: false
      t.uuid :user_id, null: false

    end

    add_index :groups_users, [:user_id, :group_id], unique: true
    add_index :groups_users, [:group_id, :user_id]

    add_foreign_key :groups_users, :users, on_delete: :cascade
    add_foreign_key :groups_users, :groups, on_delete: :cascade
  end

end
