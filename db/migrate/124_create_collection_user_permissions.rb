class CreateCollectionUserPermissions < ActiveRecord::Migration

  def change

    create_table :collection_user_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_relations, null: false, default: false, index: true

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :updator_id
      t.index :updator_id 

      t.index [:collection_id, :user_id], unique: true , name: 'idx_collection_user_permission'

      t.timestamps null: false

    end

  end

end
