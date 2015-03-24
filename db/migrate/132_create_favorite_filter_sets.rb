class CreateFavoriteFilterSets < ActiveRecord::Migration

  def change
    create_table :favorite_filter_sets, id: false do |t|
      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id
    end

    add_index :favorite_filter_sets, [:user_id, :filter_set_id], unique: true
    add_foreign_key :favorite_filter_sets, :users, on_delete: :cascade
    add_foreign_key :favorite_filter_sets, :filter_sets, on_delete: :cascade
  end

end
