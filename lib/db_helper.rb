module DBHelper
  class << self

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    ###########################################################################
    # database adapter specific
    ###########################################################################

    def file_extension
      if SQLHelper.adapter_is_postgresql? 
        "pgbin"
      elsif SQLHelper.adapter_is_mysql?
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
      ENV['PGDATABASE'] = config['database'].to_s if config['database']
    end

    def get_mysql_cmd_credentials config 
      " -u #{config['username']} --password=#{config['password'].to_s} "
    end

    def drop config = Rails.configuration.database_configuration[Rails.env]
      cmd=
        if SQLHelper.adapter_is_postgresql?
          set_pg_env config
          "dropdb #{config['database']}" 
        elsif SQLHelper.adapter_is_mysql?
          "mysql #{get_mysql_cmd_credentials config} -e 'drop database if exists #{config['database']}' "
        end
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    def create config = Rails.configuration.database_configuration[Rails.env]
      cmd=
        if SQLHelper.adapter_is_postgresql?
          set_pg_env config
          "createdb #{config['database']}"
        elsif SQLHelper.adapter_is_mysql?
          "mysql #{get_mysql_cmd_credentials config} -e 'create database #{sql_database}'"
        end
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    def dump_native options = {}
      path = options[:path] || dump_file_path
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cmd =
        if SQLHelper.adapter_is_postgresql?
          set_pg_env config
          "pg_dump -E utf-8 -F c -f #{path}"
        elsif SQLHelper.adapter_is_mysql? 
          "mysqldump #{get_mysql_cmd_credentials config} #{config['database']} > #{path}"
        else
          raise "adapter not supported"
        end
      puts "executing : #{cmd}"
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      {path: path, return_value: $?}
    end

    def restore_native path, options = {} 
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cmd =
        if SQLHelper.adapter_is_postgresql?
          set_pg_env config
          "pg_restore #{path}"
        elsif SQLHelper.adapter_is_mysql? 
          cmd = "mysql #{get_mysql_cmd_credentials config} #{config['database']} < #{path}"
        else
          raise "adapter not supported"
        end
      puts "executing : #{cmd}"
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    ###########################################################################
    # HASH / YAML import/export
    ###########################################################################
    def create_hash tables
      table_name_models = table_name_to_table_names_models tables
      Hash[
        table_name_models.map do |table_name,model| 
        query_chain= 
          if model.attribute_names.include?  model.primary_key
            model.order(model.primary_key)
          else
            model
          end
        [table_name, query_chain.all.collect(&:attributes)]
        end ]
    end


    def import_hash h, tables
      table_name_models = table_name_to_table_names_models tables
      ActiveRecord::Base.transaction do
        tables.each do |table_name|
          model = table_name_models[table_name] || table_name_models[table_name.to_s]
          # trick pg to return something for join tables
          unless model.attribute_names.include? "id" 
            model.instance_eval{set_primary_key model.attribute_names[0]}
          end
          model.attribute_names.each { |attr| model.attr_accessible attr}
          h[table_name].each do |attributes|
            model.create attributes
          end
          SQLHelper.reset_autoinc_sequence_to_max model if model.attribute_names.include? "id"
        end
        puts "the data has been imported" 
      end
    end

    private 

    def table_name_to_table_names_models tables
      Hash[ 
        tables.map do |table_name| 
        klass_name = ("raw_"+table_name).classify
        klass = Class.new(ActiveRecord::Base) do
          self.table_name = table_name
        end
        [table_name,klass]
        end ]
    end

  end
end

