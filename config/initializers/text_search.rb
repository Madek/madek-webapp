class ActiveRecord::Base

  def self.text_search_rank(column_name, search_term)
    sanitize_sql_array([%@ts_rank(to_tsvector('english',#{table_name}.#{column_name}::text), plainto_tsquery('english','%s'))@, search_term])
  end

  def self.trgm_search_rank(column_name, search_term)
    sanitize_sql_array [%@ similarity(#{table_name}.#{column_name},'%s')@, search_term]
  end

end
