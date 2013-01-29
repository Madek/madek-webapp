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

Before do 
  # The path would be wrong, it might point, it might point to some developer's homedir or the
  # persona server's home dir etc.
  AppSettings.dropbox_root_dir = (Rails.root + "tmp/dropbox").to_s
  # close any alert message to not disturb following tests
  page.driver.browser.switch_to.alert.accept rescue nil 
end


