class CreateGrouppermissions < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    create_table :grouppermissions do |t|
      t.belongs_to  :media_resource, :null => false
      t.references :group, :null => false
      t.references :permissionset, null: false, unique: true
    end

    change_table :grouppermissions do |t|
      t.index ref_id(Group)
      t.index ref_id(MediaResource)
      t.index ref_id(Permissionset)
    end

    cascade_on_delete Grouppermission, Group
    cascade_on_delete Grouppermission, MediaResource

  end

  def down
    drop_table :grouppermissions
  end
end
