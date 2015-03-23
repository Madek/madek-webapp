class CreateCollectionUserPermissions < ActiveRecord::Migration

  def change
    create_table :collection_user_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false
      t.index :get_metadata_and_previews, name: 'idx_colluserperm_get_metadata_and_previews'
      t.boolean :edit_metadata_and_relations, null: false, default: false
      t.index :edit_metadata_and_relations, name: 'idx_colluserperm_edit_metadata_and_relations'
      t.boolean :edit_permissions, null: false, default: false
      t.index :edit_permissions, name: 'idx_colluserperm_edit_permissions'

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:collection_id, :user_id], unique: true, name: 'idx_collection_user_permission'

      t.timestamps null: false

    end
  end

end
