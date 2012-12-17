require 'rubygems'
require 'pry'
require 'cucumber/rails'

ActionController::Base.allow_rescue = false

FileUtils.rm_rf("#{Rails.root}/tmp/dropbox")
FileUtils.mkdir("#{Rails.root}/tmp/dropbox")
at_exit do
  # remove dropbox 
  FileUtils.rm_rf("#{Rails.root}/tmp/dropbox")
end





