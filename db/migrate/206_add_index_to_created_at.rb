class AddIndexToCreatedAt < ActiveRecord::Migration[5.0]
  def change
    add_index :orders, :created_at
    add_index :orders, :state
    add_index :orders, :inventory_pool_id
    add_index :orders, :user_id

    add_index :contracts, :created_at
    add_index :contracts, :state
    add_index :contracts, :inventory_pool_id
    add_index :contracts, :user_id

    add_index :partitions, :inventory_pool_id
    add_index :partitions, :model_id
    add_index :partitions, :group_id
  end
end
