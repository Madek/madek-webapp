class AddRejectReasonToOrders < ActiveRecord::Migration[5.0]
  def up
    add_column :orders, :reject_reason, :string, null: true, default: nil
  end
end
