class AttachKeywordsToResources < ActiveRecord::Migration

  def change
    resources_tables = %w(media_entries collections filter_sets)

    resources_tables.each do |table_name|
      add_column :keywords, "#{table_name.singularize}_id", :uuid, index:  true
    end

    reversible do |dir|
      dir.up do

        execute "UPDATE keywords
                  SET media_entry_id= meta_data.media_entry_id,
                      collection_id= meta_data.collection_id,
                      filter_set_id= meta_data.filter_set_id
                  FROM meta_data
                  WHERE meta_data.id = keywords.meta_datum_id "

        execute %{ ALTER TABLE keywords ADD CONSTRAINT keywords_is_related CHECK
                   (   (media_entry_id IS     NULL AND collection_id IS     NULL AND filter_set_id IS NOT NULL)
                    OR (media_entry_id IS     NULL AND collection_id IS NOT NULL AND filter_set_id IS     NULL)
                    OR (media_entry_id IS NOT NULL AND collection_id IS     NULL AND filter_set_id IS     NULL))
        }

      end

    end

    add_foreign_key :keywords, :media_entries, dependent: :destroy
    add_foreign_key :keywords, :collections, dependent: :destroy
    add_foreign_key :keywords, :filter_sets, dependent: :destroy

    remove_column :keywords, :meta_datum_id, :uuid

    reversible do |dir|
      dir.up do
        execute "DELETE FROM meta_data  WHERE meta_key_id = 'keywords' "
        execute "DELETE FROM meta_key_definitions WHERE meta_key_id = 'keywords' "
        execute "DELETE FROM meta_keys WHERE id = 'keywords' "
      end
    end
  end
end
