class CreateFilterSetApiClientPermission < ActiveRecord::Migration

  include MigrationHelper

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

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_filter, null: false, default: false, index: true

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :api_client_id, null: false
      t.index :api_client_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:filter_set_id, :api_client_id], unique: true, name: 'idx_fsetapiclp_on_filter_set_id_and_api_client_id'

      t.timestamps null: false
    end

    add_foreign_key :filter_set_api_client_permissions, :api_clients, dependent: :delete
    add_foreign_key :filter_set_api_client_permissions, :filter_sets, dependent: :delete
    add_foreign_key :filter_set_api_client_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :filter_set_api_client_permissions

        ::MigrationApiClientPermission \
          .joins('JOIN filter_sets ON filter_sets.id = applicationpermissions.media_resource_id')\
          .find_each do |api_client_permission|
            attributes = api_client_permission.attributes \
              .map { |k, v| k == 'media_resource_id' ? ['filter_set_id', v] : [k, v] } \
              .reject { |k, v| %w(download manage).include? k } \
              .map { |k, v| [(API_CLIENT_PERMISSION_KEYS_MAP[k] || k), v] } \
              .instance_eval { Hash[self] }
            ::MigrationFilterSetApiClientPermission.create! attributes
        end
      end
    end
  end

end
