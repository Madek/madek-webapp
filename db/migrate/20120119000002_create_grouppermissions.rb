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
      t.index ref_id(Group)
      t.index ref_id(MediaResource)
      t.index [ref_id(Group),ref_id(MediaResource)], unique: true
    end

    fkey_cascade_on_delete Grouppermission, Group
    fkey_cascade_on_delete Grouppermission, MediaResource

  end

  def down
    drop_table :grouppermissions
  end
end
