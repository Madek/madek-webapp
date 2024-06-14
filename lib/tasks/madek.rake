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

  desc 'Delete soft deleted media entries and sets'
  task delete_soft_deleted_resources: :environment do
    puts 'Deleting soft deleted media entries and sets...'
    MediaEntry.delete_soft_deleted
    Collection.delete_soft_deleted
    puts 'Deleting soft deleted media entries and sets completed.'
  end

end
