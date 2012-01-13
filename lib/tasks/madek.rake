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

    system "bundle exec cucumber -p examples"
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
     Rake::Task["madek:init"].invoke

      # workaround for realoading Models
     ActiveRecord::Base.subclasses.each { |a| a.reset_column_information }

     Rake::Task["db:seed"].invoke
     Rake::Task["app:import_initial_metadata"].invoke

  end

  desc "Init"
  task :init => :environment do
#    Copyright.init true
#    Permission.init true
#old#    MetaKey.init true
#old#    MetaContext.init true
  end
  
  namespace :meta_data do
    desc "Set up Meta_data reference material"
    task :typevocab_data => :environment do
      # TODO replace with something that reads the YML from the config directory
    end

    desc "Only the 'keywords' meta_key can have the 'Keyword' object_type"
    task :fix_keywords => :environment do
      keywords = {}
      meta_keys = MetaKey.where(:object_type => "Keyword").where("label != 'keywords'")
      meta_keys.each do |meta_key|
        keywords[meta_key.id] = {}
        meta_key.meta_data.each do |meta_datum|
          keywords[meta_key.id][meta_datum.id] = meta_datum.deserialized_value
        end
        meta_key.update_attributes(:object_type => "Meta::Term", :is_extensible_list => true)
      end
      # we need to fetch again the meta_keys, 'cause inside the first iteration,
      # the meta_datum still keeps the reference to the old object_type
      reloaded_meta_keys = MetaKey.find(meta_keys.collect(&:id))
      reloaded_meta_keys.each do |meta_key|
        meta_key.meta_data.each do |meta_datum|
          value = keywords[meta_key.id][meta_datum.id]
          meta_term_ids = value.collect(&:meta_term_id)
          meta_key.meta_terms << Meta::Term.find(meta_term_ids - meta_key.meta_term_ids)
          meta_datum.update_attributes(:value => meta_term_ids)
          Keyword.delete(value)
        end
      end
    end
  end

  namespace :helpers do
    desc "set up helper data (country names etc)"
    task :countries => :environment do
      # TODO load up the country data
    end
  end

end # madek namespace
