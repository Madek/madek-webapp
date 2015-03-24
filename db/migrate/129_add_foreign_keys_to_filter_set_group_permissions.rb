class AddForeignKeysToFilterSetGroupPermissions < ActiveRecord::Migration

  def change
    add_foreign_key :filter_set_group_permissions, :groups, on_delete: :cascade
    add_foreign_key :filter_set_group_permissions, :filter_sets, on_delete: :cascade
    add_foreign_key :filter_set_group_permissions, :users, column: 'updator_id'
  end

end
