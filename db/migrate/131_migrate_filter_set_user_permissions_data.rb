require Rails.root.join 'db', 'migrate', 'media_resource_migration_models'

class MigrateFilterSetUserPermissionsData < ActiveRecord::Migration

  include MigrationHelper
  include MediaResourceMigrationModels

  class ::MigrationFilterSetUserPermission < ActiveRecord::Base
    self.table_name = :filter_set_user_permissions
  end

  USERPERMISSION_KEYS_MAP = {

    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata_and_filter',
    'manage' => 'edit_permissions'

  }

  def change
    reversible do |dir|
      dir.up do

        set_timestamps_defaults :filter_set_user_permissions

        ::MigrationUserPermission \
          .joins('JOIN filter_sets ON filter_sets.id = userpermissions.media_resource_id')\
          .find_each do |up|
          ::MigrationFilterSetUserPermission.create! up.attributes \
            .map { |k, v| k == 'media_resource_id' ? ['filter_set_id', v] : [k, v] } \
            .map { |k, v| [(USERPERMISSION_KEYS_MAP[k] || k), v] } \
            .reject { |k, v| k == 'download' } \
            .instance_eval { Hash[self] }

        end
      end
    end
  end

end
