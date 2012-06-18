class CreateMetaDataMetaTerms < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :meta_data_meta_terms, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :meta_term
    end

    change_table :meta_data_meta_terms  do |t|
      t.index [:meta_datum_id, :meta_term_id], unique: true
    end
    
    fkey_cascade_on_delete  :meta_data_meta_terms, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_meta_terms, ::MetaTerm

  end

  def down
    drop_table :meta_data_meta_terms
  end

end
