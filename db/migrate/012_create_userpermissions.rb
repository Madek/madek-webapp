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
      t.index :media_resource_id
      t.index :user_id
      t.index [:media_resource_id,:user_id], unique: true
    end

    add_foreign_key :userpermissions, :users, dependent: :delete
    add_foreign_key :userpermissions, :media_resources, dependent: :delete 
  end


  def down
    drop_table :userpermissions
  end

end
