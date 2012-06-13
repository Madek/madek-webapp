module DBHelper
  include SQLHelper

  class << self
    include DBHelper
  end

  def module_path # for convenient reloading
     Rails.root.join(__FILE__)
  end

  def file_extension
    if adapter_is_postgresql? 
      "pgbin"
    elsif adapter_is_mysql?
      "mysql"
    else 
      raise "adapter not supported"
    end
  end

  def dump_file_path
    date_string = DateTime.now.to_s.gsub(":","-")
    migration_version =  ActiveRecord::Migrator.current_version
    Rails.root.join "tmp", "db_dump_#{date_string}_#{migration_version}.#{file_extension}"
  end

  def set_pg_env config
    ENV['PGHOST']     = config['host']          if config['host']
    ENV['PGPORT']     = config['port'].to_s     if config['port']
    ENV['PGPASSWORD'] = config['password'].to_s if config['password']
    ENV['PGUSER']     = config['username'].to_s if config['username']
  end

  def dump_native options = {}
    path = options[:path] || dump_file_path
    config = options[:config] || Rails.configuration.database_configuration[Rails.env]
    cmd =
      if adapter_is_postgresql?
        set_pg_env config
        "pg_dump -E utf-8 -F c -f #{path}"
      elsif adapter_is_mysql? 
        raise "TODO"
      else
        raise "adapter not supported"
      end
    puts "executing : #{cmd}"
    system cmd
    {path: path, return_value: $?}
  end

  def restore_native path, options = {} 
    config = options[:config] || Rails.configuration.database_configuration[Rails.env]
    cmd =
      if adapter_is_postgresql?
        set_pg_env config
        "pg_restore #{path}"
      elsif adapter_is_mysql? 
        raise "TODO"
      else
        raise "adapter not supported"
      end
    puts "executing : #{cmd}"
    system cmd
    $?
  end

end

