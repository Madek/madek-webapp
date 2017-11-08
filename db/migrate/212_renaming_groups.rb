class RenamingGroups < ActiveRecord::Migration[5.0]
  def up

    remove_index :partitions, [:model_id, :inventory_pool_id, :group_id] #, unique: true
    remove_index :groups_users, [:user_id, :group_id] #, unique: true

    rename_table :groups, :entitlement_groups

    rename_table :groups_users, :entitlement_groups_users
    rename_column :entitlement_groups_users, :group_id, :entitlement_group_id

    rename_table :partitions, :entitlements
    rename_column :entitlements, :group_id, :entitlement_group_id

    add_index :entitlements, [:model_id, :inventory_pool_id, :entitlement_group_id],
      name: :idx_model_pool_egroup, unique: true

    add_index :entitlement_groups_users, [:user_id, :entitlement_group_id],
      name: :idx_user_egroup, unique: true

  end
end

