class CreateMetaTerms < ActiveRecord::Migration
  def change

    create_table :meta_terms do |t|
      t.string :en_gb
      t.string :de_ch
    end

    add_index :meta_terms, :en_gb
    add_index :meta_terms, :de_ch
  end

end
