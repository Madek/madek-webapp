class CreateGrouppermissions < ActiveRecord::Migration
  include MigrationHelper
  include Constants

  def change
    create_table :grouppermissions, id: :uuid do |t|

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.uuid :group_id, null: false
      t.index :group_id

      t.index [:group_id, :media_resource_id], unique: true

      MADEK_V2_PERMISSION_ACTIONS.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

    end

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE grouppermissions ADD CONSTRAINT manage_on_grouppermissions_is_false CHECK (manage = false); '
      end
    end

    add_foreign_key :grouppermissions, :groups, dependent: :delete
    add_foreign_key :grouppermissions, :media_resources, dependent: :delete
  end

end
