module DBHelper

  class << self

    def reload!
      load Rails.root.join(__FILE__)
    end

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    ###########################################################################
    # database adapter specific
    ###########################################################################

    def file_extension
      'pgsql.gz'
    end

    def base_file_name
      date_string = DateTime.now.to_s.gsub(':', '-')
      migration_version =  ActiveRecord::Migrator.current_version
      "db_dump_#{date_string}_#{migration_version}"
    end

    def dump_file_path(opts = {})
      dir = opts[:dir] || (Rails.root.join 'tmp')
      "#{dir}/#{base_file_name}.#{opts[:extension] || file_extension}"
    end

    def set_pg_env(config)
      ENV['PGHOST']     = config['host']          if config['host']
      ENV['PGPORT']     = config['port'].to_s     if config['port']
      ENV['PGPASSWORD'] = config['password'].to_s if config['password']
      ENV['PGUSER']     = config['username'].to_s if config['username']
      ENV['PGDATABASE'] = config['database'].to_s if config['database']
    end

    ###########################################################################
    # dump and restore data only
    ###########################################################################

    def dump_data(options = {})
      options = options.symbolize_keys
      path = options[:path] || dump_file_path(options.merge(extension: 'pgsql'))
      set_pg_env (options[:config] ||
                  Rails.configuration.database_configuration[Rails.env])
      cmd = "pg_dump -x -T schema_migrations -E utf-8 -a --no-acl -f #{path}"
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      { path: path, return_value: $? }
    end

    def dump(options = {})
      options = options.symbolize_keys
      path = options[:path] || dump_file_path(options.merge(extension: 'pgbin'))
      set_pg_env (options[:config] ||
                  Rails.configuration.database_configuration[Rails.env])
      cmd = "pg_dump -x -E utf-8 -F c -f #{path}"
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      { path: path, return_value: $? }
    end

    def load_data(path, options = {})
      config = options[:config] || Rails.configuration.database_configuration[Rails.env]
      set_pg_env config
      cond_unzip_pipe = case path.to_s
                        when /\.gz$/
                          '| gunzip'
                        else
                          ''
                        end
      cmd = "cat #{path} #{cond_unzip_pipe} | psql -q #{config['database']}"
      system cmd
      raise "#{cmd} failed" unless $?.exitstatus == 0
      $?
    end

    def truncate_tables
      ActiveRecord::Base.connection.tap do |connection|
        connection.tables.reject { |tn|tn == 'schema_migrations' }.join(', ').tap do |tables|
          connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
        end
      end
    end

  end
end
