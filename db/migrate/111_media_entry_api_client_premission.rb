class MediaEntryApiClientPremission < ActiveRecord::Migration
  include MigrationHelper

  class ::MigrationApiClientpermission < ActiveRecord::Base
    self.table_name = :applicationpermissions
  end

  class ::MigrationMediaEntryApiClientpermission < ActiveRecord::Base
    self.table_name = :media_entry_api_client_permissions
  end

  API_CLIENTPERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews',
    'download' => 'get_full_size' }

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

    add_foreign_key :media_entry_api_client_permissions, :api_clients, dependent: :delete
    add_foreign_key :media_entry_api_client_permissions, :media_entries, dependent: :delete
    add_foreign_key :media_entry_api_client_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :media_entry_api_client_permissions

        ::MigrationApiClientpermission \
          .joins('JOIN media_entries ON media_entries.id = applicationpermissions.media_resource_id')\
          .find_each do |up|
          ::MigrationMediaEntryApiClientpermission.create! up.attributes \
            .map { |k, v| k == 'media_resource_id' ? ['media_entry_id', v] : [k, v] } \
            .map { |k, v| [(API_CLIENTPERMISSION_KEYS_MAP[k] || k), v] } \
            .reject { |k, v| %w(manage edit).include? k } \
            .instance_eval { Hash[self] }

        end
      end
    end
  end

end
