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
  # close any alert message to not disturb following tests
  page.driver.browser.switch_to.alert.accept rescue nil 
end


# see https://github.com/cucumber/gherkin/issues/245
Gherkin::I18n.class_eval do
  alias_method :orig_lexer, :lexer
  def lexer(listener, force_ruby=false)
    orig_lexer(listener,true)
  end
end


# TODO remove this when 'fixed'
require 'multi_test' 
MultiTest.disable_autorun


