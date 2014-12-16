class AddCreatedAtToFavorites < ActiveRecord::Migration

  def change
    [:favorite_media_entries, :favorite_collections, :favorite_filter_sets].each do |table_name|
      add_column table_name, :created_at, :datetime
      execute "UPDATE #{table_name} SET created_at = now();"
      change_column table_name, :created_at, :datetime, null: false
    end
  end

end
