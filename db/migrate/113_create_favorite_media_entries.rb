class CreateFavoriteMediaEntries < ActiveRecord::Migration

  def change
    create_table :favorite_media_entries, id: false do |t|
      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :media_entry_id, null: false
      t.index :media_entry_id
    end

    add_index :favorite_media_entries, [:user_id, :media_entry_id], unique: true
    add_foreign_key :favorite_media_entries, :users, dependent: :delete
    add_foreign_key :favorite_media_entries, :media_entries, dependent: :delete
  end

end
