class CreateUserpermissions < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up 

    create_table :userpermissions do |t|
      t.references :media_resource, null: false
      t.references :permissionset, null: false
      t.references :user, null: false
    end

    change_table :userpermissions do |t|
      t.index ref_id(MediaResource)
      t.index  ref_id(Permissionset)
      t.index  ref_id(User)
    end

    cascade_on_delete Userpermission, User
    cascade_on_delete Userpermission, MediaResource

  end


  def down
    drop_table :userpermissions
  end

end
