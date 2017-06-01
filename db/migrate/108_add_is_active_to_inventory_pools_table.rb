class AddIsActiveToInventoryPoolsTable < ActiveRecord::Migration
  def change
    add_column :inventory_pools, :is_active, :boolean, default: true, null: false
  end
end
