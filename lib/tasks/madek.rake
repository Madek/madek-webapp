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


  desc "Fetch meta information from ldap, store it into db/ldap.json and update meta_departments"
  task :fetch_ldap => :environment do
    DevelopmentHelpers.fetch_from_ldap
    DevelopmentHelpers.update_meta_departments_from_ldap_localfile
  end

  desc "Reset"
  task :reset => :environment do
     Rake::Task["app:setup:make_directories"].execute(:reset => "reset")
     Rake::Task["log:clear"].invoke
      # workaround for realoading Models
     ActiveRecord::Base.subclasses.each { |a| a.reset_column_information }
  end
  
end # madek namespace
