module SQLHelper

  # all methods in here are real functions! we can include them in
  # the eigenclass, so they are callable as module/class methods:
  # TODO remove all "self." and test
  class << self
    include SQLHelper
  end

  def self.execute_sql query
    ActiveRecord::Base.connection.execute query 
  end

  def self.adapter_name
     ActiveRecord::Base.connection.adapter_name
  end


  def self.adapter_is_mysql?
    adapter_name == "Mysql2"
  end

  def self.adapter_is_postgresql?
    adapter_name == "PostgreSQL"
  end


  def self.database_name
    Rails.configuration.database_configuration[Rails.env]["database"]
  end

  def self.table_names
    if adapter_is_postgresql?
      (execute_sql "SELECT tablename from pg_tables where tableowner = 'rails' AND tablename <> 'schema_migrations' ORDER BY tablename").values.flatten
    elsif adapter_is_mysql?
      (execute_sql %Q@ SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE table_type = "BASE TABLE" AND TABLE_SCHEMA = "#{database_name}" @).to_a.flatten
    end
  end

  def self.bitwise_is action,i
    if SQLHelper.adapter_is_mysql?
      " #{action} & #{i} "
    elsif SQLHelper.adapter_is_postgresql?
      "(#{action} & #{i})>0 "
    else 
      raise "unsupported db adapter"
    end
  end

  def self.reset_autoinc_sequence_to_max model
    if adapter_is_postgresql?
      execute_sql %Q{ select setval('#{model.table_name}_id_seq',(SELECT max(id) from #{model.table_name})); }
    end
  end


end
