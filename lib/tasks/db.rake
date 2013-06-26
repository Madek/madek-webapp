# monkey patch dump so it includes data
# TODO fix this for rails4

require 'active_support/core_ext/object/inclusion'
require 'active_record'

db_namespace = namespace :db do

  namespace :structure do
    desc 'Dump the database structure to db/structure.sql. Specify another file with DB_STRUCTURE=db/my_structure.sql'
    task :dump => [:environment, :load_config] do
      config = current_config
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      case config['adapter']
      when /mysql/, 'oci', 'oracle'
        ActiveRecord::Base.establish_connection(config)
        File.open(filename, "w:utf-8") { |f| f << ActiveRecord::Base.connection.structure_dump }
      when /postgresql/
        set_psql_env(config)
        search_path = config['schema_search_path']
        unless search_path.blank?
          search_path = search_path.split(",").map{|search_path_part| "--schema=#{Shellwords.escape(search_path_part.strip)}" }.join(" ")
        end
        # CHANGED removed -s switch, do not omit the data
        `pg_dump --inserts -i -x -O -f #{Shellwords.escape(filename)} #{search_path} #{Shellwords.escape(config['database'])}`
        raise 'Error dumping database' if $?.exitstatus == 1
        File.open(filename, "a") { |f| f << "SET search_path TO #{ActiveRecord::Base.connection.schema_search_path};\n\n" }
      when /sqlite/
        dbfile = config['database']
        `sqlite3 #{dbfile} .schema > #{filename}`
      when 'sqlserver'
        `smoscript -s #{config['host']} -d #{config['database']} -u #{config['username']} -p #{config['password']} -f #{filename} -A -U`
      when "firebird"
        set_firebird_env(config)
        db_string = firebird_db_string(config)
        sh "isql -a #{db_string} > #{filename}"
      else
        raise "Task not supported by '#{config['adapter']}'"
      end

      # CHAGED we already have the migration versions
      # if ActiveRecord::Base.connection.supports_migrations?
      #   File.open(filename, "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
      # end
      db_namespace['structure:dump'].reenable
    end
  end
end
