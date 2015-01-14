# it is important that this file is loaded prior to any 
# code that is to be checked for coverage 
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails'
  Dir[Rails.root.join('app/**/*.rb')].each { |f| require f }
  puts "required simplecov from #{__FILE__}"
end
