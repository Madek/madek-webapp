require 'digest'
require 'action_controller'

namespace :madek do

  desc 'Reset'
  task reset: :environment do
    Rake::Task['app:setup:make_directories'].execute(reset: 'reset')
    Rake::Task['log:clear'].invoke
    # workaround for realoading Models
    ActiveRecord::Base.subclasses.each(&:reset_column_information)
  end

  desc 'Produce daily notification emails'
  task produce_daily_emails: :environment do
    puts 'Producing daily notification emails...'
    Notification.produce_daily_emails
    puts 'Producing daily notification emails completed.'
  end

  desc 'Produce weekly notification emails'
  task produce_weekly_emails: :environment do
    puts 'Producing weekly notification emails...'
    Notification.produce_weekly_emails
    puts 'Producing weekly notification emails completed.'
  end

end # madek namespace
