# -*- encoding : utf-8 -*-
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Madek::Application.initialize!

Haml::Template.options[:ugly] = true
