# -*- encoding : utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MAdeK::Application.initialize!

require "#{Rails.root}/lib/red_cloth_madek.rb"
Irwi.config.formatter = RedClothMadek.new
