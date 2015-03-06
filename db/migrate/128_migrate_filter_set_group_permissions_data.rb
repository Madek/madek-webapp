require Rails.root.join 'db', 'migrate', 'media_resource_migration_models'

class MigrateFilterSetGroupPermissionsData < ActiveRecord::Migration

  include MigrationHelper
  include MediaResourceMigrationModels

  class ::MigrationFilterSetGroupPermission < ActiveRecord::Base
    self.table_name = :filter_set_group_permissions
  end

  GROUPPERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews'
  }

  def change
    reversible do |dir|
      dir.up do

        set_timestamps_defaults :filter_set_group_permissions

        ::MigrationGroupPermission \
          .joins('JOIN filter_sets ON filter_sets.id = grouppermissions.media_resource_id')\
          .find_each do |group_permission|
            attributes = group_permission.attributes \
              .map { |k, v| k == 'media_resource_id' ? ['filter_set_id', v] : [k, v] } \
              .reject { |k, v| %w(edit download manage).include? k } \
              .map { |k, v| [(GROUPPERMISSION_KEYS_MAP[k] || k), v] } \
              .instance_eval { Hash[self] }
            ::MigrationFilterSetGroupPermission.create! attributes
        end
      end
    end
  end

end
