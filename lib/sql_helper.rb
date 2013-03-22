module SQLHelper

  # all methods in here are real functions! we can include them in
  # the eigenclass, so they are callable as module/class methods:
  class << self
    include SQLHelper
  end

  def execute_sql query
    ActiveRecord::Base.connection.execute query 
  end

  def reset_autoinc_sequence_to_max model
    execute_sql %Q{ select setval('#{model.table_name}_id_seq',(SELECT max(id) from #{model.table_name})); }
  end

end
