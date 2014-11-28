class AddColumnsToEditSessions < ActiveRecord::Migration

  def change

    resources_tables= %w(media_entries collections filter_sets)

    resources_tables.each do |table_name|
      add_column :edit_sessions, "#{table_name.singularize}_id", :uuid, index:  true
    end

  end
end
