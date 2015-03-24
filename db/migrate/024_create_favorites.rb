class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites, id: false do |t|
      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id
    end

    add_index :favorites, [:user_id, :media_resource_id], unique: true
    add_foreign_key :favorites, :users, on_delete: :cascade
    add_foreign_key :favorites, :media_resources, on_delete: :cascade
  end

end
