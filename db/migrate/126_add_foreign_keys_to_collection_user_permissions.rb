class AddForeignKeysToCollectionUserPermissions < ActiveRecord::Migration

  def change
    add_foreign_key :collection_user_permissions, :users, on_delete: :cascade
    add_foreign_key :collection_user_permissions, :collections, on_delete: :cascade
    add_foreign_key :collection_user_permissions, :users, column: 'updator_id'
  end

end
