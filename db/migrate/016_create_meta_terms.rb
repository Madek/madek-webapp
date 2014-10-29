class CreateMetaTerms < ActiveRecord::Migration
  include MigrationHelper

  def change

    create_table :meta_terms, id: :uuid do |t|
      t.text :term, null: false, default: ''
      t.index :term, unique: true
    end

    reversible do |dir|
      dir.up do 
        create_trgm_index :meta_terms, :term
        create_text_index :meta_terms, :term
      end
    end


  end

end
