require Rails.root.join "db","migrate","media_resource_migration_models"

class RelinkMetadata < ActiveRecord::Migration
  include MigrationHelper
  include MediaResourceMigrationModels

  def change

    change_table :meta_data do |t|

      t.uuid :media_entry_id
      t.index :media_entry_id

      t.uuid :collection_id
      t.index :collection_id

      t.uuid :filter_set_id
      t.index :filter_set_id

    end

    reversible do |dir|
      dir.up do 

        execute "UPDATE meta_data 
                  SET media_entry_id = media_resources.id
                  FROM media_resources
                  WHERE media_resources.id = meta_data.media_resource_id
                  AND media_resources.type = 'MediaEntry'"

        execute "UPDATE meta_data 
                  SET collection_id = media_resources.id
                  FROM media_resources
                  WHERE media_resources.id = meta_data.media_resource_id
                  AND media_resources.type = 'MediaSet'"

        execute "UPDATE meta_data 
                  SET filter_set_id = media_resources.id
                  FROM media_resources
                  WHERE media_resources.id = meta_data.media_resource_id
                  AND media_resources.type = 'FilterSet'"

        execute %{ ALTER TABLE meta_data ADD CONSTRAINT meta_data_is_related CHECK 
                   (   (media_entry_id IS     NULL AND collection_id IS     NULL AND filter_set_id IS NOT NULL) 
                    OR (media_entry_id IS     NULL AND collection_id IS NOT NULL AND filter_set_id IS     NULL)
                    OR (media_entry_id IS NOT NULL AND collection_id IS     NULL AND filter_set_id IS     NULL))
                      };
      end

      reversible do |dir|
        dir.up do 
          execute "ALTER TABLE meta_data DROP COLUMN media_resource_id CASCADE"
        end
        dir.down do
          add_column :meta_data, :media_resource_id, :uuid
        end
      end

      add_foreign_key :meta_data, :media_entries
      add_foreign_key :meta_data, :collections
      add_foreign_key :meta_data, :filter_sets

    end

  end

end
