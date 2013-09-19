#!/usr/bin/env ruby
require 'yaml'

$LOAD_PATH << './domina_rails/lib'
require 'domina_rails/database'

config = YAML.load_file("config/database.yml")["test"]
DominaRails::Database.drop_db config
