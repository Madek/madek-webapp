class CreateFilterSetUserPermission < ActiveRecord::Migration

  include MigrationHelper

  class ::MigrationUserPermission < ActiveRecord::Base
    self.table_name= :userpermissions 
  end

  class ::MigrationFilterSetUserPermission < ActiveRecord::Base
    self.table_name= :filter_set_user_permissions
  end

  USER_PERMISSION_KEYS_MAP= {
    "view" => "get_metadata_and_previews",
    "edit" => "edit_metadata_and_filter", 
    "manage" => "edit_permissions", }


  def change

    create_table :filter_set_user_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_filter, null: false, default: false, index: true
      t.boolean :edit_permissions, null: false, default: false, index: true

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :updator_id
      t.index :updator_id 

      t.index [:filter_set_id,:user_id], unique: true, name: 'idx_fsetusrp_on_filter_set_id_and_user_id'

      t.timestamps null: false
    end

    add_foreign_key :filter_set_user_permissions, :users, dependent: :delete
    add_foreign_key :filter_set_user_permissions, :filter_sets, dependent: :delete 
    add_foreign_key :filter_set_user_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :filter_set_user_permissions

        ::MigrationUserPermission \
          .joins("JOIN filter_sets ON filter_sets.id = #{MigrationUserPermission.table_name}.media_resource_id")\
          .find_each do |user_permission|
            attributes= user_permission.attributes \
              .map{|k,v| k == "media_resource_id" ? ["filter_set_id",v] : [k,v]} \
              .reject{|k,v| %w(download).include? k } \
              .map{|k,v| [ (USER_PERMISSION_KEYS_MAP[k] || k), v]} \
              .instance_eval{Hash[self]}
            puts "MIGRATING #{user_permission.attributes} to #{attributes}"
          ::MigrationFilterSetUserPermission.create! attributes
        end
      end
    end

  end

end
