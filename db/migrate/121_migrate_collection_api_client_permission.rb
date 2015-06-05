class MigrateCollectionApiClientPermission < ActiveRecord::Migration

  include MigrationHelper

  class ::MigrationApiClient < ActiveRecord::Base
    self.table_name = :api_clients
  end

  class ::MigrationApiClientPermission < ActiveRecord::Base
    self.table_name = :applicationpermissions
  end

  def change
    create_table :collection_api_client_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false
      t.index :get_metadata_and_previews, name: 'idx_collapiclp_get_mdata_and_previews'
      t.boolean :edit_metadata_and_relations, null: false, default: false
      t.index :edit_metadata_and_relations, name: 'idx_collapiclp_edit_mdata_and_relations'

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.uuid :api_client_id, null: false
      t.index :api_client_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:collection_id, :api_client_id], unique: true, name: 'idx_collapiclp_on_collection_id_and_api_client_id'

      t.timestamps null: false
    end

    add_foreign_key :collection_api_client_permissions, :api_clients, on_delete: :cascade
    add_foreign_key :collection_api_client_permissions, :collections, on_delete: :cascade
    add_foreign_key :collection_api_client_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :collection_api_client_permissions

        ::MigrationApiClientPermission \
          .joins('JOIN collections ON collections.id = applicationpermissions.media_resource_id')\
          .find_each do |old|
            new_id = (::MigrationApiClient.find_by login: old.application_id).id

            execute \
              "INSERT INTO collection_api_client_permissions " \
              "(collection_id, api_client_id, " \
              "get_metadata_and_previews, edit_metadata_and_relations)" \
              "VALUES ('#{old.media_resource_id}', '#{new_id}', " \
              "'#{old.view}', '#{old.edit}')"

        end
      end
    end
  end

end
