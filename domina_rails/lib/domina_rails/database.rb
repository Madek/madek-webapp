require 'domina_rails/system'

module DominaRails
  module Database
    class << self

      def set_pg_env config
        puts "set_pg_env with #{config.pretty_inspect}"

        ENV['PGHOST']     = config['host']          if config['host']
        ENV['PGPORT']     = config['port'].to_s     if config['port']
        ENV['PGPASSWORD'] = config['password'].to_s if config['password']
        ENV['PGUSER']     = config['username'].to_s if config['username']
        ENV['PGDATABASE'] = config['database'].to_s if config['database']
      end

      def create_db config
        set_pg_env config
        puts DominaRails::System.execute_cmd! "env | grep 'PG' | sort"
        puts DominaRails::System.execute_cmd! "dropdb --if-exists #{config['database']}"
        puts DominaRails::System.execute_cmd! "createdb #{config['database']}"
      end

      def drop_db config
        set_pg_env config
        puts DominaRails::System.execute_cmd! "dropdb --if-exists #{config['database']}"
      end

    end
  end
end

