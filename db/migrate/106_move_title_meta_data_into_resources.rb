class MoveTitleMetaDataIntoResources < ActiveRecord::Migration
  def change

    resources_tables= %w(media_entries collections filter_sets)

    resources_tables.each do |table_name|
      add_column table_name, :title, :text
    end

    reversible do |dir|
      dir.up do

        resources_tables.each do |table_name|

          execute "UPDATE #{table_name}
                  SET title= meta_data.string
                  FROM meta_data
                  WHERE meta_data.#{table_name.singularize}_id = #{table_name}.id
                  AND meta_data.meta_key_id = 'title' " 

                  execute "UPDATE #{table_name}
                  SET title = 'Ohne Title'
                  WHERE title IS NULL 
                    OR title = '';"

                  change_column table_name, :title, :text, null: false

        end

        execute "DELETE FROM meta_data  WHERE meta_key_id = 'title' "
        execute "DELETE FROM meta_key_definitions WHERE meta_key_id = 'title' "
        execute "DELETE FROM meta_keys WHERE id = 'title' "

      end
    end
  end
end
