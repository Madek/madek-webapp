class MigrateFilterSetApiClientPermission < ActiveRecord::Migration

  include MigrationHelper

  class ::MigrationApiClient < ActiveRecord::Base
    self.table_name = :api_clients
  end

  class ::MigrationApiClientPermission < ActiveRecord::Base
    self.table_name = :applicationpermissions
  end

  class ::MigrationFilterSetApiClientPermission < ActiveRecord::Base
    self.table_name = :filter_set_api_client_permissions
  end

  API_CLIENT_PERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata_and_filter' }

  def change
    create_table :filter_set_api_client_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false
      t.index :get_metadata_and_previews, name: 'idx_fsetapiclp_get_mdata_and_previews'
      t.boolean :edit_metadata_and_filter, null: false, default: false
      t.index :edit_metadata_and_filter, name: 'idx_fsetapiclp_edit_mdata_and_filter'

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :api_client_id, null: false
      t.index :api_client_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:filter_set_id, :api_client_id], unique: true, name: 'idx_fsetapiclp_on_filter_set_id_and_api_client_id'

      t.timestamps null: false
    end

    add_foreign_key :filter_set_api_client_permissions, :api_clients, on_delete: :cascade
    add_foreign_key :filter_set_api_client_permissions, :filter_sets, on_delete: :cascade
    add_foreign_key :filter_set_api_client_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do |old|

        set_timestamps_defaults :filter_set_api_client_permissions

        ::MigrationApiClientpermission \
          .joins('JOIN filter_sets ON filter_sets.id = applicationpermissions.media_resource_id')\
          .find_each do |old|
            new_id = (::MigrationApiClient.find_by login: old.application_id).id

            execute \
              "INSERT INTO filter_set_api_client_permissions " \
              "(filter_set_id, api_client_id, " \
              "get_metadata_and_previews, edit_metadata_and_filter)" \
              "VALUES ('#{old.media_resource_id}', '#{new_id}', " \
              "'#{old.view}', '#{old.edit}')"
        end
      end
    end
  end

end
