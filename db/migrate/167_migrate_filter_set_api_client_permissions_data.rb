require Rails.root.join 'db', 'migrate', 'media_resource_migration_models'

class MigrateFilterSetApiClientPermissionsData < ActiveRecord::Migration

  include MigrationHelper
  include MediaResourceMigrationModels

  class ::MigrationApiClientpermission < ActiveRecord::Base
    self.table_name = :applicationpermissions
  end

  class ::MigrationFilterSetApiClientPermission < ActiveRecord::Base
    self.table_name = :filter_set_api_client_permissions
  end

  USERPERMISSION_KEYS_MAP = {

    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata_and_filter'

  }

  def change
    reversible do |dir|
      dir.up do

        set_timestamps_defaults :filter_set_api_client_permissions

        ::MigrationApiClientpermission \
          .joins('JOIN filter_sets ON filter_sets.id = applicationpermissions.media_resource_id')\
          .find_each do |up|
          ::MigrationFilterSetApiClientPermission.create! up.attributes \
            .map { |k, v| k == 'media_resource_id' ? ['filter_set_id', v] : [k, v] } \
            .map { |k, v| [(USERPERMISSION_KEYS_MAP[k] || k), v] } \
            .reject { |k, v| k == 'download' } \
            .reject { |k, v| k == 'manage' } \
            .instance_eval { Hash[self] }

        end
      end
    end
  end

end
