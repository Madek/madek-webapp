module DBHelper

  class << self

    def reload! 
      load Rails.root.join(__FILE__)
    end

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def max_migration
      ActiveRecord::Migrator.migrations(ActiveRecord::Migrator.migrations_path).map(&:version).max
    end

    def completly_migrated
      unless @completly_migrated
        stdouts = `rake db:migrate:status RAILS_ENV=#{Rails.env}`
        @completly_migrated = stdouts.scan(/\n/).size > 1 and stdouts.match(/\n  down/)
      end
      @completly_migrated
    end

    ###########################################################################
    # database adapter specific
    ###########################################################################

    def file_extension
      "pgsql.gz"
    end

    def base_file_name
      date_string = DateTime.now.to_s.gsub(":","-")
      migration_version =  ActiveRecord::Migrator.current_version
      "db_dump_#{date_string}_#{migration_version}"
    end

    def dump_file_path opts={}
      dir = opts[:dir] || (Rails.root.join "tmp")
      "#{dir}/#{base_file_name}.#{file_extension}"
    end

    def set_pg_env config
      ENV['PGHOST']     = config['host']          if config['host']
      ENV['PGPORT']     = config['port'].to_s     if config['port']
      ENV['PGPASSWORD'] = config['password'].to_s if config['password']
      ENV['PGUSER']     = config['username'].to_s if config['username']
      ENV['PGDATABASE'] = config['database'].to_s if config['database']
    end

    def drop config = Rails.configuration.database_configuration[Rails.env]
      cmd= begin
             set_pg_env config
             "dropdb #{config['database']}" 
           end
      ActiveRecord::Base.remove_connection
      terminate_open_connections config
      system cmd
      ActiveRecord::Base.establish_connection
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    def create_from_template config, template_config
      set_pg_env template_config
      cmd = "psql -q -c 'CREATE DATABASE \"#{config['database']}\" TEMPLATE = \"#{template_config['database']}\"'"
      system cmd
    end

    def create config = Rails.configuration.database_configuration[Rails.env]
      cmd= begin
             set_pg_env config
             "createdb #{config['database']}"
           end
      ActiveRecord::Base.remove_connection
      system cmd
      ActiveRecord::Base.establish_connection
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    ###########################################################################
    # admin
    ###########################################################################

    def terminate_open_connections config
      pid_name =  ENV['PGPIDNAME']  || "procpid"
      set_pg_env config
      stdout = `psql template1 -c \"SELECT pg_terminate_backend(pg_stat_activity.#{pid_name}) FROM pg_stat_activity WHERE pg_stat_activity.datname = '#{config['database']}';\" 2>&1`
      unless $?.exitstatus == 0 
        puts "TERMINATING OPEN PG CONNECTIONS FAILED, set the PGPIDNAME env variable to pid if you are using postgresql 9.2 or later"
      end
      {status: $?.exitstatus,output: stdout}
    end

    ###########################################################################
    # dump and restore
    ###########################################################################

    def dump_native options = {}
      options = options.symbolize_keys
      path = options[:path] || dump_file_path(options)
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cmd =
        begin
          set_pg_env config
          "pg_dump -E utf-8 -F p -Z 5 -O --no-acl -f #{path}"
        end
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      {path: path, return_value: $?}
    end

    def restore_native path, options = {} 
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cond_unzip_pipe = case path.to_s
                   when /\.gz$/
                     "| gunzip"
                   else
                     ""
                   end
      cmd = "cat #{path} #{cond_unzip_pipe} | psql -q #{config['database'].to_s}"
      ActiveRecord::Base.remove_connection
      terminate_open_connections config
      system cmd
      begin # the following may fail if we call from outside an working env
      ActiveRecord::Base.establish_connection
      rescue => e
      end
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

