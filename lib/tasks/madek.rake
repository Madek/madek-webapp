require 'digest'
require 'action_controller'

namespace :madek do

  desc "Set up the environment for testing, then run tests"
  task :test do
    # Rake seems to be very stubborn about where it takes
    # the RAILS_ENV from, so let's set a lot of options (?)

    Rails.env = 'test'
    task :environment
    Rake::Task["madek:reset"].invoke
    system "bundle exec rspec --format d --format html --out tmp/html/rspec.html spec"
    exit_code = $? >> 8 # magic brainfuck
    raise "Tests failed with: #{exit_code}" if exit_code != 0

    system "bundle exec cucumber -p default"
    exit_code = $? >> 8 # magic brainfuck
    raise "Tests failed with: #{exit_code}" if exit_code != 0

    # Skip this so we can see if the red stuff in is in there
    system "bundle exec cucumber -p examples"
    exit_code = $? >> 8 # magic brainfuck
    raise "Tests failed with: #{exit_code}" if exit_code != 0

    system "bundle exec cucumber -p current_examples"
    exit_code = $? >> 8 # magic brainfuck
    raise "Tests failed with: #{exit_code}" if exit_code != 0
  end

  desc "Back up images and database before doing anything silly"
  task :backup do
   unless Rails.env == "production"
     puts "HOLD IT! Are you sure you don't want to run this in production mode?"
     puts "Exiting."
     exit
   end

   puts "Copying attachment files."
   system "cp -apr /home/rails/madek/data_medienarchiv/attachments /home/rails/madek/data_medienarchiv/attachments-#{date_string}.bak"
   dump_database  
  end

  task :dump_database do
   unless Rails.env == "production"
     puts "HOLD IT! Are you sure you don't want to run this in production mode?"
     puts "Exiting."
     exit
   end

   date_string = DateTime.now.to_s.gsub(":","-")
   config = Rails.configuration.database_configuration[Rails.env]
   sql_host     = config["host"]
   sql_database = config["database"]
   sql_username = config["username"]
   sql_password = config["password"]
   dump_path =  "/home/rails/madek/shared/db_backups/#{sql_database}-#{date_string}.sql"

   puts "Dumping database"
   system "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"
   puts "Compressing database with bzip2"
   system "bzip2 #{dump_path}"

  end

  namespace :db  do

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

  desc "Fetch meta information from ldap and store it into db/ldap.json"
  task :fetch_ldap => :environment do
    DevelopmentHelpers.fetch_from_ldap
  end

# CONSTANTS used here are in environment.rb
  desc "Reset"
  task :reset => :environment  do |t,args|
    
      def rm_and_mkdir(path)
        puts "Removing #{path}"
        system "rm -rf '#{path}'"
        puts "Creating #{path}"
        system "mkdir -p #{path}"
      end
    
      # If any of the paths are either nil or set to ""...
      if [FILE_STORAGE_DIR, THUMBNAIL_STORAGE_DIR, TEMP_STORAGE_DIR, DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR].map{|path| path.to_s}.uniq == ""
        puts "DANGER, EXITING: The file storage paths are not defined! You need to define FILE_STORAGE_DIR, THUMBNAIL_STORAGE_DIR, TEMP_STORAGE_DIR, DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR in your config/application.rb"
        exit        
      else
        if (File.exist?(FILE_STORAGE_DIR) and File.exist?(THUMBNAIL_STORAGE_DIR))
          puts "Deleting #{FILE_STORAGE_DIR} and #{THUMBNAIL_STORAGE_DIR}"
          system "rm -rf '#{FILE_STORAGE_DIR}' '#{THUMBNAIL_STORAGE_DIR}'"         
        end
      
        [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ].each do |h|
          puts "Creating #{FILE_STORAGE_DIR}/#{h} and #{THUMBNAIL_STORAGE_DIR}/#{h}"
          system "mkdir -p #{FILE_STORAGE_DIR}/#{h} #{THUMBNAIL_STORAGE_DIR}/#{h}"
        end
      
        rm_and_mkdir(TEMP_STORAGE_DIR)
        rm_and_mkdir(DOWNLOAD_STORAGE_DIR)
        rm_and_mkdir(ZIP_STORAGE_DIR)
      end
      
     Rake::Task["log:clear"].invoke
     Rake::Task["db:migrate:reset"].invoke

      # workaround for realoading Models
     ActiveRecord::Base.subclasses.each { |a| a.reset_column_information }

     Rake::Task["db:seed"].invoke

     Rake::Task["madek:meta_data:import_presets"].invoke

  end
  
  namespace :meta_data do

    desc "Export MetaData Presets" 
    task :export_presets  => :environment do

      data_hash = DevelopmentHelpers::MetaDataPreset.create_hash

      date_string = DateTime.now.to_s.gsub(":","-")
      file_path = "tmp/#{date_string}_meta_data.yml"

      File.open(file_path, "w"){|f| f.write data_hash.to_yaml } 
      puts "the file has been saved to #{file_path}"
      puts "you might wish to copy it to features data "
    end

    desc "Import MetaData Presets" 
    task :import_presets => :environment do
      DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
    end

  end


end # madek namespace
