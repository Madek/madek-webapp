class CreateCollectionGroupPermission < ActiveRecord::Migration

  include MigrationHelper

  class ::MigrationGroupPermission < ActiveRecord::Base
    self.table_name = :grouppermissions
  end

  class ::MigrationCollectionGroupPermission < ActiveRecord::Base
    self.table_name = :collection_group_permissions
  end

  GROUPPERMISSION_KEYS_MAP = {
    'view' => 'get_metadata_and_previews',
    'edit' => 'edit_metadata_and_relations' }

  def change
    create_table :collection_group_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_relations, null: false, default: false, index: true

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.uuid :group_id, null: false
      t.index :group_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:collection_id, :group_id], unique: true, name: 'idx_colgrpp_on_collection_id_and_group_id'

      t.timestamps null: false
    end

    add_foreign_key :collection_group_permissions, :groups, dependent: :delete
    add_foreign_key :collection_group_permissions, :collections, dependent: :delete
    add_foreign_key :collection_group_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :collection_group_permissions

        ::MigrationGroupPermission \
          .joins('JOIN collections ON collections.id = grouppermissions.media_resource_id')\
          .find_each do |group_permission|
            attributes = group_permission.attributes \
              .map { |k, v| k == 'media_resource_id' ? ['collection_id', v] : [k, v] } \
              .reject { |k, v| %w(download manage).include? k } \
              .map { |k, v| [(GROUPPERMISSION_KEYS_MAP[k] || k), v] } \
              .instance_eval { Hash[self] }
            puts "MIGRATING #{group_permission.attributes} to #{attributes}"
            ::MigrationCollectionGroupPermission.create! attributes
        end
      end
    end
  end

end
