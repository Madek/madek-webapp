class CreateMediaEntryGrouppermission < ActiveRecord::Migration

  include MigrationHelper

  class ::MigrationGroupPermission < ActiveRecord::Base
    self.table_name = :grouppermissions
  end

  class ::MigrationMediaEntryGroupPermission < ActiveRecord::Base
    self.table_name = :media_entry_group_permissions
  end

  GROUPPERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata',
    'download' => 'get_full_size' }

  def change
    create_table :media_entry_group_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false
      t.index :get_metadata_and_previews, name: 'idx_megrpp_get_mdata_and_previews'
      t.boolean :get_full_size, null: false, default: false, index: true
      t.boolean :edit_metadata, null: false, default: false, index: true

      t.uuid :media_entry_id, null: false
      t.index :media_entry_id

      t.uuid :group_id, null: false
      t.index :group_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:media_entry_id, :group_id], unique: true, name: 'idx_megrpp_on_media_entry_id_and_group_id'

      t.timestamps null: false
    end

    add_foreign_key :media_entry_group_permissions, :groups, on_delete: :cascade
    add_foreign_key :media_entry_group_permissions, :media_entries, on_delete: :cascade
    add_foreign_key :media_entry_group_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :media_entry_group_permissions

        ::MigrationGroupPermission \
          .joins('JOIN media_entries ON media_entries.id = grouppermissions.media_resource_id')\
          .find_each do |up|
          ::MigrationMediaEntryGroupPermission.create! up.attributes \
            .map { |k, v| k == 'media_resource_id' ? ['media_entry_id', v] : [k, v] } \
            .map { |k, v| [(GROUPPERMISSION_KEYS_MAP[k] || k), v] } \
            .reject { |k, v| k == 'manage' } \
            .instance_eval { Hash[self] }

        end
      end
    end
  end

end
