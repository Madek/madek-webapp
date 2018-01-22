class AddIndexToSupplierItems < ActiveRecord::Migration[5.0]
  def change
    add_index :items, :supplier_id
  end
end
