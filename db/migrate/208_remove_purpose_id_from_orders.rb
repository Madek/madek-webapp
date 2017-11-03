class RemovePurposeIdFromOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :purpose_id
  end
end
