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

  desc "Reset"
  task :reset => :environment do
     Rake::Task["app:setup:make_directories[reset]"].invoke
     
     system "rm -f tmp/*.mysql" 
     Rake::Task["log:clear"].invoke
     Rake::Task["db:migrate:reset"].invoke

      # workaround for realoading Models
     ActiveRecord::Base.subclasses.each { |a| a.reset_column_information }

     Rake::Task["db:seed"].invoke
  end
  
end # madek namespace
