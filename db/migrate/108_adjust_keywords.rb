class AdjustKeywords < ActiveRecord::Migration

  def change

    execute "DELETE FROM keywords WHERE meta_datum_id IS NULL OR keyword_term_id IS NULL;"
    
    change_column :keywords, :keyword_term_id, :uuid, null: false
    change_column :keywords, :meta_datum_id, :uuid, null: false
  end

end
