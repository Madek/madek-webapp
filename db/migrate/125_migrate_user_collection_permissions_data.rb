require Rails.root.join "db","migrate","media_resource_migration_models"
require Rails.root.join "db","migrate","user_permission_keys_definition"

class MigrateUserCollectionPermissionsData < ActiveRecord::Migration

  include MigrationHelper
  include MediaResourceMigrationModels
  include UserPermissionKeysDefinition

  class ::MigrationCollectionUserPermission < ActiveRecord::Base
    self.table_name= :collection_user_permissions
  end

  def change

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :collection_user_permissions

        ::MigrationUserPermission \
          .joins("JOIN collections ON collections.id = userpermissions.media_resource_id")\
          .find_each do |up|
          ::MigrationCollectionUserPermission.create! up.attributes \
            .map {|k, v| k == "media_resource_id" ? ["collection_id", v] : [k, v]} \
            .map {|k, v| [ (USERPERMISSION_KEYS_MAP[k] || k), v]} \
            .instance_eval { Hash[self] }

        end
      end
    end

  end

end
