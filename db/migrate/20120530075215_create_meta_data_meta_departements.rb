class CreateMetaDataMetaDepartements < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :meta_data_meta_departements, :id => false do |t|
      t.belongs_to :meta_datum
      t.integer :meta_departement_id
    end

    add_index :meta_data_meta_departements,  
      [:meta_datum_id, :meta_departement_id], 
      name: "index_meta_data_meta_departements_datum_group",
      unique: true

    fkey_cascade_on_delete  :meta_data_meta_departements, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_meta_departements, ::Group, :meta_departement_id

  end

  def down
    drop_table :meta_data_meta_departements
  end

end
