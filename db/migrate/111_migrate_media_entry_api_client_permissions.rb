class MigrateMediaEntryApiClientPermissions < ActiveRecord::Migration
  include MigrationHelper

  class ::MigrationApiClientpermission < ActiveRecord::Base
    self.table_name = :applicationpermissions
  end

  class ::MigrationApiClient < ActiveRecord::Base
    self.table_name = :api_clients
  end

  def change
    create_table :media_entry_api_client_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false
      t.index :get_metadata_and_previews, name: 'idx_me_apicl_get_mdata_and_previews'
      t.boolean :get_full_size, null: false, default: false, index: true
      t.index :get_full_size, name: 'idx_megrpp_get_full_size'

      t.uuid :media_entry_id, null: false
      t.index :media_entry_id

      t.uuid :api_client_id, null: false
      t.index :api_client_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:media_entry_id, :api_client_id], unique: true, name: 'idx_megrpp_on_media_entry_id_and_api_client_id'

      t.timestamps null: false
    end

    add_foreign_key :media_entry_api_client_permissions, :api_clients, on_delete: :cascade
    add_foreign_key :media_entry_api_client_permissions, :media_entries, on_delete: :cascade
    add_foreign_key :media_entry_api_client_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :media_entry_api_client_permissions

        ::MigrationApiClientpermission \
          .joins('JOIN media_entries ON media_entries.id = applicationpermissions.media_resource_id')\
          .find_each do |old|
            new_id = (::MigrationApiClient.find_by login: old.application_id).id

            execute \
              "INSERT INTO media_entry_api_client_permissions " \
              "(media_entry_id, api_client_id, " \
              "get_metadata_and_previews, get_full_size)" \
              "VALUES ('#{old.media_resource_id}', '#{new_id}', " \
              "'#{old.view}', '#{old.download}')"

        end
      end
    end
  end

end
