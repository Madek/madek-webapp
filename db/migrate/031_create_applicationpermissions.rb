class CreateApplicationpermissions < ActiveRecord::Migration
  include Constants
  include MigrationHelper

  def change
    create_table :applicationpermissions, id: :uuid do |t|
      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.string :application_id, null: false
      t.index :application_id

      t.index [:media_resource_id, :application_id], name: 'index_applicationpermissions_on_mr_id_and_app_id', unique: true

      ACTIONS.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

    end

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE applicationpermissions ADD CONSTRAINT manage_on_applicationpermissions_is_false CHECK (manage = false); '
        execute 'ALTER TABLE applicationpermissions ADD CONSTRAINT edit_on_applicationpermissions_is_false CHECK (edit = false); '
      end
    end

    add_foreign_key :applicationpermissions, :applications, dependent: :delete
    add_foreign_key :applicationpermissions, :media_resources, dependent: :delete
  end

end
