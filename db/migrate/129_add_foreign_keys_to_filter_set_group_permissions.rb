class AddForeignKeysToFilterSetGroupPermissions < ActiveRecord::Migration

  def change
    add_foreign_key :filter_set_group_permissions, :groups, dependent: :delete
    add_foreign_key :filter_set_group_permissions, :filter_sets, dependent: :delete
    add_foreign_key :filter_set_group_permissions, :users, column: 'updator_id'
  end

end
