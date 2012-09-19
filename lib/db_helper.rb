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
        "pgsql.gz"
      elsif SQLHelper.adapter_is_mysql?
        "mysql"
      else 
        raise "adapter not supported"
      end
    end

    def base_file_name
      date_string = DateTime.now.to_s.gsub(":","-")
      migration_version =  ActiveRecord::Migrator.current_version
      "db_dump_#{date_string}_#{migration_version}"
    end

    def dump_file_path
      Rails.root.join "tmp", "#{base_file_name}.#{file_extension}"
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
      ActiveRecord::Base.remove_connection
      system cmd
      ActiveRecord::Base.establish_connection
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    def create_from_template config, template_config
      unless  SQLHelper.adapter_is_postgresql?
        raise "not supported"
      end
      set_pg_env template_config
      cmd = "psql -q -c 'CREATE DATABASE #{config['database']} TEMPLATE = #{template_config['database']}'"
      system cmd
    end

    def create_from_template_for_mysql config = Rails.configuration.database_configuration[Rails.env], options = {}
      template_config = options[:template_config]
      DBHelper.dump_native({:config => template_config, :path => Rails.root + 'tmp/template_dump.mysql'})
      cmd = "mysql #{get_mysql_cmd_credentials config} -e 'create database #{config['database']}'"
      system(cmd)
      result = DBHelper.restore_native(Rails.root + 'tmp/template_dump.mysql', config)
      return result
    end

    def dump_native options = {}
      path = options[:path] || dump_file_path
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cmd =
        if SQLHelper.adapter_is_postgresql?
          set_pg_env config
          "pg_dump -E utf-8 -F p -Z 5 -f #{path}"
        elsif SQLHelper.adapter_is_mysql? 
          "mysqldump #{get_mysql_cmd_credentials config} #{config['database']} > #{path}"
        else
          raise "adapter not supported"
        end
      ActiveRecord::Base.remove_connection
      system cmd
      ActiveRecord::Base.establish_connection
      raise "#{cmd} failed" unless $?.exitstatus == 0
      {path: path, return_value: $?}
    end

    def restore_native path, options = {} 
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cmd =
        if SQLHelper.adapter_is_postgresql?
          set_pg_env config
          "cat #{path} | gunzip | psql -q #{config['database'].to_s}"
        elsif SQLHelper.adapter_is_mysql? 
          cmd = "mysql #{get_mysql_cmd_credentials config} #{config['database']} < #{path}"
        else
          raise "adapter not supported"
        end
      ActiveRecord::Base.remove_connection
      system cmd
      ActiveRecord::Base.establish_connection
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    ###########################################################################
    # HASH / YAML import/export
    ###########################################################################
    def create_hash tables, env = nil

      if env
        dbconf = YAML::load_file Rails.root.join('config','database.yml')
        ActiveRecord::Base.remove_connection
        ActiveRecord::Base.establish_connection dbconf[env]
      end

      table_name_models = table_name_to_table_names_models tables
      Hash[
        table_name_models.map do |table_name,model| 
        puts "#{Time.now} reading #{table_name}"
        query_chain= 
          if model.attribute_names.include?  model.primary_key
            model.order(model.primary_key)
          else
            model
          end
        [table_name, query_chain.all.collect(&:attributes)]
        end ]
    end


    def import_hash h, tables, env = nil

      if env
        dbconf = YAML::load_file Rails.root.join('config','database.yml')
        ActiveRecord::Base.remove_connection
        ActiveRecord::Base.establish_connection dbconf[env]
      end

      table_name_models = table_name_to_table_names_models tables
      ActiveRecord::Base.transaction do
        tables.each do |table_name|
          puts "#{Time.now} writing #{table_name}"
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

    def reset_autoinc_sequences tables, env = nil
      if env
        dbconf = YAML::load_file Rails.root.join('config','database.yml')
        ActiveRecord::Base.remove_connection
        ActiveRecord::Base.establish_connection dbconf[env]
      end
 
      table_name_models = table_name_to_table_names_models tables
      tables.each do |table_name|
        model = table_name_models[table_name] || table_name_models[table_name.to_s]
        SQLHelper.reset_autoinc_sequence_to_max model if model.attribute_names.include? "id"
      end
    end

    ###########################################################################
    # Transfer
    ###########################################################################
    def transfer tables, source_env, target_env
      h = create_hash tables, source_env
      import_hash h, tables, target_env
    end

    ###########################################################################
    # Compare
    ###########################################################################

    def compare tables, source_env, target_env
      source_h = create_hash tables, source_env
      target_h = create_hash tables, target_env
      if source_h == target_h
        puts "the databases have equal content"
      else
        puts "the databases differ"
        puts deep_diff(source_h,target_h).to_yaml
      end
    end

    def deep_diff d1, d2
      if d1.is_a? Hash and d2.is_a? Hash
        d1.select {|k| d1[k] != d2[k] }.map{ |k,v| {k => deep_diff(d1[k],d2[k])}}
      elsif d1.is_a? Array and d2.is_a? Array
        (d1 | d2) - ( d1 & d2)
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

