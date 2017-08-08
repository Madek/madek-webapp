class AddIsActiveToInventoryPoolsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :inventory_pools, :is_active, :boolean, default: true, null: false
  end
end
