class AlterMetaDataSchema < ActiveRecord::Migration
  include MigrationHelpers
  
  def up
    add_column :meta_keys, :meta_datum_object_type, :string
    add_column :meta_data, :type, :string
    add_column :meta_data, :string, :text

    add_column :meta_data, :copyright_id, :integer
    add_index :meta_data, :copyright_id
    fkey_cascade_on_delete ::MetaDatum, ::Copyright


    create_table :meta_data_people, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :person
    end
    change_table :meta_data_people  do |t|
      t.index [:meta_datum_id, :person_id], unique: true
    end
    fkey_cascade_on_delete  :meta_data_people, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_people, ::Person


    create_table :meta_data_meta_departments, :id => false do |t|
      t.belongs_to :meta_datum
      t.integer :meta_department_id
    end
    add_index :meta_data_meta_departments, [:meta_datum_id, :meta_department_id], name: "index_meta_data_meta_departments_datum_group", unique: true
    fkey_cascade_on_delete  :meta_data_meta_departments, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_meta_departments, ::Group, :meta_department_id


    create_table :meta_data_meta_terms, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :meta_term
    end
    change_table :meta_data_meta_terms  do |t|
      t.index [:meta_datum_id, :meta_term_id], unique: true
    end
    fkey_cascade_on_delete  :meta_data_meta_terms, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_meta_terms, ::MetaTerm


    create_table :meta_data_users, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :user
    end
    change_table :meta_data_users  do |t|
      t.index [:meta_datum_id, :user_id], unique: true
    end
    fkey_cascade_on_delete  :meta_data_users, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_users, ::User

    MigrationHelpers::MetaDatum::RawMetaDatum.reset_column_information

    change_table :keywords  do |t|
      t.belongs_to :meta_datum
      t.index :meta_datum_id
    end
    fkey_cascade_on_delete  :keywords, ::MetaDatum

  end

  def down
    remove_column :keywords, :meta_datum_id

    drop_table :meta_data_users
    drop_table :meta_data_meta_terms
    drop_table :meta_data_meta_departments
    drop_table :meta_data_people

    remove_column :meta_data, :copyright_id
    remove_column :meta_data, :string
    remove_column :meta_data, :type
    remove_column :meta_keys, :meta_datum_object_type
  end

end

