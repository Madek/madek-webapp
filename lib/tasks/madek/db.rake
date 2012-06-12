namespace :madek do
  namespace :db  do

    desc "Dump the database from whatever DB to YAML"
    task :dump_to_yaml => :environment do
      date_string = DateTime.now.to_s.gsub(":","-")
      file_path = "tmp/db-dump-#{Rails.env}-#{date_string}.yml" 
      data_hash = DevelopmentHelpers::DumpAndRestoreTables.create_hash Constants::ALL_TABLES
      File.open(file_path, "w"){|f| f.write data_hash.to_yaml } 
      puts "the file has been saved to #{file_path}"
    end

    desc "Restore the DB from YAML" 
    task :restore_from_yaml => :environment do
      if file_name= ENV['FILE']
        h = YAML.load File.read file_name
        DevelopmentHelpers::DumpAndRestoreTables.import_hash h, Constants::ALL_TABLES
      else
        raise "missing FILE env varialbe"
      end
    end

    # TODO 
    # we have a lot of duplication between PG and MY
    # refactor the core functionallity out to lib/sql_helper
    desc "Dump the PostgresDB"
    task :dump_pg do
      date_string = DateTime.now.to_s.gsub(":","-")
      config = Rails.configuration.database_configuration[Rails.env]
      sql_host     = config["host"]
      sql_database = config["database"]
      sql_username = config["username"]
      sql_password = config["password"]
      date_string = DateTime.now.to_s.gsub(":","-")
      path = "tmp/db-dump-#{Rails.env}-#{date_string}.pgbin" 
      puts "Dumping database to #{path}"
      cmd = "pg_dump -U #{sql_username} -h #{sql_host} -v -E utf-8 -F c -f #{path} #{sql_database}"
      puts "executing : #{cmd}"
      system cmd 
    end

    desc "Restore the PostgresDB" 
    task :restore_pg => :environment do
      unless ENV['FILE'] 
        puts "can't find the FILE env variable, bailing out"
        exit
      end
      puts "dropping the db" 
      Rake::Task["db:drop"].invoke
      puts "creating the db"  
      Rake::Task["db:create"].invoke
      config = Rails.configuration.database_configuration[Rails.env]
      sql_host     = config["host"]
      sql_database = config["database"]
      sql_username = config["username"]
      sql_password = config["password"]
      file= ENV['FILE']
      cmd = "pg_restore -U #{sql_username} -d #{sql_database} #{file}"
      puts "executing: #{cmd}"
      system cmd
    end

    desc "Dump the MySqlDB"
    task :dump_my do
      date_string = DateTime.now.to_s.gsub(":","-")
      config = Rails.configuration.database_configuration[Rails.env]
      sql_host     = config["host"]
      sql_database = config["database"]
      sql_username = config["username"]
      sql_password = config["password"]
      date_string = DateTime.now.to_s.gsub(":","-")
      path = "tmp/db-dump-#{Rails.env}-#{date_string}.mysql" 
      puts "Dumping database to #{path}"
      cmd = "mysqldump -u #{sql_username} --password=#{sql_password} #{sql_database} > #{path}"
      puts "executing : #{cmd}"
      system cmd 
    end

    desc "Restore the MySqlDB" 
    task :restore_my => :environment do
      unless ENV['FILE'] 
        puts "can't find the FILE env variable, bailing out"
        exit
      end
      puts "dropping the db" 
      Rake::Task["db:drop"].invoke
      puts "creating the db"  
      Rake::Task["db:create"].invoke
      config = Rails.configuration.database_configuration[Rails.env]
      sql_host     = config["host"]
      sql_database = config["database"]
      sql_username = config["username"]
      sql_password = config["password"]
      file= ENV['FILE']
      cmd = "mysql -u #{sql_username} --password=#{sql_password} #{sql_database} < #{file}"
      puts "executing: #{cmd}"
      system cmd
    end

  end
end
