class AddForeignKeysToCollectionUserPermissions < ActiveRecord::Migration

  def change

    add_foreign_key :collection_user_permissions, :users, dependent: :delete
    add_foreign_key :collection_user_permissions, :collections, dependent: :delete 
    add_foreign_key :collection_user_permissions, :users, column: 'updator_id'

  end

end
