class CreateGrouppermissions < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up
    create_table :grouppermissions do |t|

      t.belongs_to  :media_resource, :polymorphic => true, :null => false
      t.references :group, :null => false

      ACTIONS.each do |action|
        t.boolean "may_#{action}", :default => false
      end

    end

    add_index :grouppermissions, ref_id(Group)
    add_index :grouppermissions, :media_resource_id
    add_index :grouppermissions, :media_resource_type

    ACTIONS.each do |action|
      add_index :grouppermissions, "may_#{action}"
    end

    fkey_cascade_on_delete :grouppermissions, :group_id, :groups
 

  end

  def down
    drop_table :grouppermissions
  end
end
