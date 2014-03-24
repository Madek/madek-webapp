class CreateApplicationpermissions < ActiveRecord::Migration
  include Constants

  def up 

    create_table :applicationpermissions, id: false do |t|
      t.uuid :id, null: false, default: 'uuid_generate_v4()'
      t.uuid :media_resource_id, null: false
      t.string :application_id, null: false
      Actions.each do |action|
        t.boolean action, null: false, default: false, index: true
      end
    end

    execute %[ALTER TABLE applicationpermissions ADD PRIMARY KEY (id)]

    change_table :applicationpermissions do |t|
      t.index :media_resource_id
      t.index :application_id
      t.index [:media_resource_id,:application_id], name: 'index_applicationpermissions_on_mr_id_and_app_id', unique: true
    end

    add_foreign_key :applicationpermissions, :applications, dependent: :delete
    add_foreign_key :applicationpermissions, :media_resources, dependent: :delete

    execute "ALTER TABLE applicationpermissions ADD CONSTRAINT manage_on_applicationpermissions_is_false CHECK (manage = false); "
    execute "ALTER TABLE applicationpermissions ADD CONSTRAINT edit_on_applicationpermissions_is_false CHECK (edit = false); "

  end

  def down
    drop_table :applicationpermissions
  end

end
