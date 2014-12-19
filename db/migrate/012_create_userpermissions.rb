class CreateUserpermissions < ActiveRecord::Migration
  include Constants

  def change
    create_table :userpermissions, id: :uuid do |t|

      MADEK_V2_PERMISSION_ACTIONS.each do |action|
        t.boolean action, null: false, default: false, index: true
      end

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.uuid :user_id, null: false
      t.index :user_id

      t.index [:media_resource_id, :user_id], unique: true

    end

    add_foreign_key :userpermissions, :users, dependent: :delete
    add_foreign_key :userpermissions, :media_resources, dependent: :delete
  end

end
