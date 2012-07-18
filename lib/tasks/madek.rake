require 'digest'
require 'action_controller'

namespace :madek do

  desc "Set up the environment for testing, then run all tests in one block"
  task :test => 'test:run_all'

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
   if Rails.env == "production"
    dump_path =  Rails.root.join("..", "..", "shared","db_backups","#{sql_database}-#{date_string}.sql")
   else
    dump_path = Rails.root.join("tmp","#{sql_database}-#{date_string}.sql")
   end

   puts "Dumping database"
   system "mysqldump -h #{sql_host} --user=#{sql_username} --password=#{sql_password} -r #{dump_path} #{sql_database}"
   puts "Compressing database with bzip2"
   system "bzip2 #{dump_path}"
   
   # output the pathname at the end
   puts "#{dump_path}.bz2"

  end


  desc "Fetch meta information from ldap and store it into db/ldap.json"
  task :fetch_ldap => :environment do
    DevelopmentHelpers.fetch_from_ldap
  end

  # FIXME this should be :make_missing_directories ??
  # CONSTANTS used here are in production.rb
  desc "Create needed directories"
  task :make_directories => :environment do
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
    
      [TEMP_STORAGE_DIR, DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR].each do |path|
        puts "Removing #{path}"
        system "rm -rf '#{path}'"
        puts "Creating #{path}"
        system "mkdir -p #{path}"
      end
    end
  end

  desc "Reset"
  task :reset => :environment do |t,args|
     Rake::Task["madek:make_directories"].invoke
     
     system "rm -f tmp/*.mysql" 
     Rake::Task["log:clear"].invoke
     Rake::Task["db:migrate:reset"].invoke

      # workaround for realoading Models
     ActiveRecord::Base.subclasses.each { |a| a.reset_column_information }

     Rake::Task["db:seed"].invoke
  end
  
end # madek namespace
