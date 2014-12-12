require Rails.root.join 'db', 'migrate', 'media_resource_migration_models'

class CreateMediaEntryUserPermissions < ActiveRecord::Migration
  include MigrationHelper
  include MediaResourceMigrationModels

  class ::MigrationMediaEntryUserPermission < ActiveRecord::Base
    self.table_name = :media_entry_user_permissions
  end

  USERPERMISSION_KEYS_MAP = {

    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata',
    'download' => 'get_full_size',
    'manage' => 'edit_permissions'

  }

  def change
    create_table :media_entry_user_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :get_full_size, null: false, default: false, index: true
      t.boolean :edit_metadata, null: false, default: false, index: true
      t.boolean :edit_permissions, null: false, default: false, index: true

      t.uuid :media_entry_id, null: false
      t.index :media_entry_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:media_entry_id, :user_id], unique: true, name: 'idx_media_entry_user_permission'

      t.timestamps null: false
    end

    add_foreign_key :media_entry_user_permissions, :users, dependent: :delete
    add_foreign_key :media_entry_user_permissions, :media_entries, dependent: :delete
    add_foreign_key :media_entry_user_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :media_entry_user_permissions

        ::MigrationUserPermission \
          .joins('JOIN media_entries ON media_entries.id = userpermissions.media_resource_id')\
          .find_each do |up|
          ::MigrationMediaEntryUserPermission.create! up.attributes \
            .map { |k, v| k == 'media_resource_id' ? ['media_entry_id', v] : [k, v] } \
            .map { |k, v| [(USERPERMISSION_KEYS_MAP[k] || k), v] } \
            .instance_eval { Hash[self] }

        end
      end
    end
  end

end
