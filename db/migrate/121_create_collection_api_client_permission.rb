class CreateCollectionApiClientPermission < ActiveRecord::Migration

  include MigrationHelper

  class ::MigrationApiClientPermission < ActiveRecord::Base
    self.table_name= :applicationpermissions 

  end

  class ::MigrationCollectionApiClientPermission < ActiveRecord::Base
    self.table_name= :collection_api_client_permissions
  end

  API_CLIENT_PERMISSION_KEYS_MAP= {
    "view" => "get_metadata_and_previews",
    "edit" => "edit_metadata_and_relations", }


  def change

    create_table :collection_api_client_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_relations, null: false, default: false, index: true

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.string :api_client_id, null: false
      t.index :api_client_id

      t.uuid :updator_id
      t.index :updator_id 

      t.index [:collection_id,:api_client_id], unique: true, name: 'idx_collapiclp_on_collection_id_and_api_client_id'

      t.timestamps null: false
    end

    add_foreign_key :collection_api_client_permissions, :api_clients, dependent: :delete
    add_foreign_key :collection_api_client_permissions, :collections, dependent: :delete 
    add_foreign_key :collection_api_client_permissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :collection_api_client_permissions

        ::MigrationApiClientPermission \
          .joins("JOIN collections ON collections.id = applicationpermissions.media_resource_id")\
          .find_each do |api_client_permission|
            attributes= api_client_permission.attributes \
              .map{|k,v| k == "media_resource_id" ? ["collection_id",v] : [k,v]} \
              .reject{|k,v| %w(download manage).include? k } \
              .map{|k,v| [ (API_CLIENT_PERMISSION_KEYS_MAP[k] || k), v]} \
              .instance_eval{Hash[self]}
            puts "MIGRATING #{api_client_permission.attributes} to #{attributes}"
          ::MigrationCollectionApiClientPermission.create! attributes
        end
      end
    end

  end

end
