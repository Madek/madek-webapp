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

end # madek namespace
