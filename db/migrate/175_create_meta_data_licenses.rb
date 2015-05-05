class CreateMetaDataLicenses < ActiveRecord::Migration
  def change
    create_table :meta_data_licenses, id: false do |t|
      t.uuid :meta_datum_id, null: false
      t.uuid :license_id, null: false
    end

    add_index :meta_data_licenses, [:meta_datum_id, :license_id], unique: true
    add_foreign_key :meta_data_licenses, :meta_data, on_delete: :cascade
    add_foreign_key :meta_data_licenses, :licenses
  end
end
