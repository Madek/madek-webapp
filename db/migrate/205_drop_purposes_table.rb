class DropPurposesTable < ActiveRecord::Migration[5.0]
  def change
    remove_column :reservations, :purpose_id
    drop_table :purposes
  end
end
