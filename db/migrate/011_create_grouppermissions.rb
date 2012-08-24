class CreateGrouppermissions < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    create_table :grouppermissions do |t|
      t.belongs_to  :media_resource, :null => false
      t.references :group, :null => false
      Actions.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

    end

    change_table :grouppermissions do |t|
      t.index :group_id
      t.index :media_resource_id
      t.index [:group_id,:media_resource_id], unique: true
    end
      
    add_foreign_key :grouppermissions, :groups, dependent: :delete
    add_foreign_key :grouppermissions, :media_resources, dependent: :delete

  end

  def down
    drop_table :grouppermissions
  end
end
