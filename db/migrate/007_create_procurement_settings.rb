class CreateProcurementSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :procurement_settings, id: :uuid do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.index :key, unique: true
    end
  end
end
