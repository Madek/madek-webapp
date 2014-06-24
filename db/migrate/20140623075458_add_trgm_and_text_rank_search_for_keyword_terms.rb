class AddTrgmAndTextRankSearchForKeywordTerms < ActiveRecord::Migration
  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end

  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def up  
    create_trgm_index :keyword_terms, :term
    create_text_index :keyword_terms, :term
  end

  def down
    remove_column :keyword_terms, :trgm_searchable
  end
end
