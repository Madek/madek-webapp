class CreateFavoriteFilterSets < ActiveRecord::Migration

  def change
    create_table :favorite_filter_sets, id: false do |t|
      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id
    end

    add_index :favorite_filter_sets, [:user_id, :filter_set_id], unique: true
    add_foreign_key :favorite_filter_sets, :users, dependent: :delete
    add_foreign_key :favorite_filter_sets, :filter_sets, dependent: :delete
  end

end
