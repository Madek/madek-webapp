class CreateMediaEntryUserpermissions < ActiveRecord::Migration
  include MigrationHelper

  class ::MigrationUserpermission < ActiveRecord::Base
    self.table_name= :userpermissions
  end

  class ::MigrationMediaEntryUserpermission < ActiveRecord::Base
    self.table_name= :media_entry_userpermissions
  end


  def change

    create_table :media_entry_userpermissions, id: :uuid do |t|

      t.boolean :view, null: false, default: false, index: true
      t.boolean :download, null: false, default: false, index: true
      t.boolean :edit, null: false, default: false, index: true
      t.boolean :manage, null: false, default: false, index: true

      t.uuid :media_entry_id, null: false
      t.index :media_entry_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.uuid :updator_id
      t.index :updator_id 

      t.index [:media_entry_id,:user_id], unique: true

      t.timestamps null: false
    end

    add_foreign_key :media_entry_userpermissions, :users, dependent: :delete
    add_foreign_key :media_entry_userpermissions, :media_entries, dependent: :delete 
    add_foreign_key :media_entry_userpermissions, :users, column: 'updator_id'

    reversible do |dir|
      dir.up do

        set_timestamps_defaults :media_entry_userpermissions

        ::MigrationUserpermission \
          .joins("JOIN media_entries ON media_entries.id = userpermissions.media_resource_id")\
          .find_each do |up|
          ::MigrationMediaEntryUserpermission.create! up.attributes \
            .map{|k,v| k == "media_resource_id" ? ["media_entry_id",v] : [k,v]} \
            .instance_eval{Hash[self]}

        end
      end
    end

  end

end
