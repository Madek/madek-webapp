namespace :madek do
  namespace :db  do

    desc "Dump the database to YAML"
    task :dump_to_yaml => :environment do
      date_string = DateTime.now.to_s.gsub(":","-")
      path = "db/pg-dump-#{Rails.env}-#{date_string}.bin" 

      config = Rails.configuration.database_configuration[Rails.env]
      sql_host     = config["host"]
      sql_database = config["database"]
      sql_username = config["username"]
      sql_password = config["password"]
      date_string = DateTime.now.to_s.gsub(":","-")
      path = "tmp/pg-dump-#{Rails.env}-#{date_string}.bin" 
      puts "Dumping database to #{path}"
      cmd = "pg_dump -U #{sql_username} -h #{sql_host} -v -E utf-8 -F c -f #{path} #{sql_database}"
      puts "executing : #{cmd}"
      system cmd 
    end


    desc "Dump the PostgresDB"
    task :dump do
      date_string = DateTime.now.to_s.gsub(":","-")
      config = Rails.configuration.database_configuration[Rails.env]
      sql_host     = config["host"]
      sql_database = config["database"]
      sql_username = config["username"]
      sql_password = config["password"]
      date_string = DateTime.now.to_s.gsub(":","-")
      path = "tmp/pg-dump-#{Rails.env}-#{date_string}.bin" 
      puts "Dumping database to #{path}"
      cmd = "pg_dump -U #{sql_username} -h #{sql_host} -v -E utf-8 -F c -f #{path} #{sql_database}"
      puts "executing : #{cmd}"
      system cmd 
    end
    
    desc "Restore the PostgresDB" 
    task :restore do
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

  end

end

