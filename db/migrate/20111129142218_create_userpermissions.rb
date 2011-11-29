class CreateUserpermissions < ActiveRecord::Migration
  def change
    create_table :userpermissions do |t|

      t.timestamps
    end
  end
end
