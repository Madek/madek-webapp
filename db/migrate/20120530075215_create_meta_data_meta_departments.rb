class CreateMetaDataMetaDepartments < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :meta_data_meta_departments, :id => false do |t|
      t.belongs_to :meta_datum
      t.integer :meta_department_id
    end

    add_index :meta_data_meta_departments,  
      [:meta_datum_id, :meta_department_id], 
      name: "index_meta_data_meta_departments_datum_group",
      unique: true

    fkey_cascade_on_delete  :meta_data_meta_departments, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_meta_departments, ::Group, :meta_department_id

  end

  def down
    drop_table :meta_data_meta_departments
  end

end
