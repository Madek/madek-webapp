module SQLHelper

  # all methods in here are real functions! we can include them in
  # the eigenclass, so they are callable as module/class methods:
  class << self
    include SQLHelper
  end

  def adapter_name
    begin
      ActiveRecord::Base.connection().adapter_name().downcase
    rescue
      Rails.configuration.database_configuration[Rails.env]["adapter"].downcase
    end
  end

  def execute_sql query
    ActiveRecord::Base.connection.execute query 
  end

  def adapter_is_mysql?
    ["mysql", "mysql2"].include?  adapter_name
  end

  def adapter_is_postgresql?
    ["postgresql","jdbcpostgresql"].include?(adapter_name)
  end

  def ilike
    if SQLHelper.adapter_is_postgresql?
      " ilike "
    else
      " like "
    end
  end

  def reset_autoinc_sequence_to_max model
    if adapter_is_postgresql?
      execute_sql %Q{ select setval('#{model.table_name}_id_seq',(SELECT max(id) from #{model.table_name})); }
    end
  end

end
