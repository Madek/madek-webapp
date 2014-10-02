# it is important that this file is loaded prior to any 
# code that is to be checked for coverage 
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails'
  puts "required simplecov"
end
