class AddTrgmSearchForMetaTerms < ActiveRecord::Migration
  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end

  def up
    add_column :meta_terms, :trgm_searchable, :text, default: "", null: false 
    MetaTerm.all.each do |meta_term| 
      meta_term.update_trgm_searchable
    end
    create_trgm_index :meta_terms, :trgm_searchable
  end

  def down
    remove_column :meta_terms, :trgm_searchable
  end
end
