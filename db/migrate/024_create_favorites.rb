class CreateFavorites < ActiveRecord::Migration
  def up
    create_table :favorites, id: false do |t|
      t.integer :user_id, null: false
      t.integer :media_resource_id, null: false
    end
    add_index :favorites, [:user_id,:media_resource_id], unique: true
    add_foreign_key :favorites, :users, dependent: :delete
    add_foreign_key :favorites, :media_resources, dependent: :delete
  end

  def down
    drop_table :favorites
  end
end
