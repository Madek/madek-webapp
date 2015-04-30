class AddTimestampsToFavorites < ActiveRecord::Migration

  def change
    [:favorite_media_entries, :favorite_collections, :favorite_filter_sets].each do |table_name|
      %i(created_at updated_at).each do |column_name|
        add_column table_name, column_name, :datetime
        execute "UPDATE #{table_name} SET #{column_name} = now();"
        change_column table_name, column_name, :datetime, null: false
      end
    end
  end

end
