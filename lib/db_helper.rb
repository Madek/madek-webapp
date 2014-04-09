module DBHelper

  #  pg_dump -a -O -x -T schema_migrations --disable-triggers -f tmp/data.sql  madek_dev

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
      "#{dir}/#{base_file_name}.#{opts[:extension] || file_extension}"
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
      cmd = "psql -d template1 -q -c 'CREATE DATABASE \"#{config['database']}\" TEMPLATE = \"#{template_config['database']}\"'"
      Rails.logger.debug "executing: #{cmd}"
      output = `#{cmd}`
      raise "ERROR executing #{cmd} with output: #{output}" if $?.exitstatus != 0
      output
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
    # dump and restore data only 
    ###########################################################################
  
    def dump_data options= {}
      options = options.symbolize_keys
      path = options[:path] || dump_file_path(options.merge({extension: 'pqsql'}))
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cmd =
        begin
          set_pg_env config
          "pg_dump -x -T schema_migrations --disable-triggers -E utf-8 -a -O --no-acl -f #{path}"
        end
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      {path: path, return_value: $?}
    end

    def load_data path, options = {} 
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      cond_unzip_pipe = case path.to_s
                   when /\.gz$/
                     "| gunzip"
                   else
                     ""
                   end
      cmd = "cat #{path} #{cond_unzip_pipe} | psql -q #{config['database'].to_s}"
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    def truncate_tables
      ActiveRecord::Base.connection.tap do |connection|
        connection.tables.reject{|tn|tn=="schema_migrations"}.join(', ').tap do |tables|
          connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
        end
      end
    end

    ###########################################################################
    # dump and restore with schema
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

  end
end

