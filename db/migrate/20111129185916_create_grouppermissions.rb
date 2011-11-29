class CreateGrouppermissions < ActiveRecord::Migration
  def change
    create_table :grouppermissions do |t|

      t.timestamps
    end
  end
end
