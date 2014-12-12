class CreateFavoriteCollections < ActiveRecord::Migration

  def change
    create_table :favorite_collections, id: false do |t|
      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :collection_id, null: false
      t.index :collection_id
    end

    add_index :favorite_collections, [:user_id, :collection_id], unique: true
    add_foreign_key :favorite_collections, :users, dependent: :delete
    add_foreign_key :favorite_collections, :collections, dependent: :delete
  end

end
