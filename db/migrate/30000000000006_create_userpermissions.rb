class CreateUserpermissions < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up 

    create_table :userpermissions do |t|
      t.references :media_resource, null: false
      t.references :user, null: false
      Actions.each do |action|
        t.boolean action, null: false, default: false, index: true
      end
    end

    change_table :userpermissions do |t|
      t.index ref_id(MediaResource)
      t.index ref_id(User)
      t.index [ref_id(MediaResource),ref_id(User)], unique: true
    end

    fkey_cascade_on_delete Userpermission, User
    fkey_cascade_on_delete Userpermission, MediaResource

  end


  def down
    drop_table :userpermissions
  end

end
