class AddSearchableToMetaTerms < ActiveRecord::Migration
  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def up
    add_column :meta_terms, :searchable, :text, default: "", null: false
    MetaTerm.all.each do |meta_term| 
      meta_term.update_searchable
    end
    create_text_index :meta_terms, :searchable
  end

  def down
    remove_column :meta_terms, :searchable
  end
end
