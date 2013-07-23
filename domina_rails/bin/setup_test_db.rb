#!/usr/bin/env ruby
require 'yaml'

$LOAD_PATH << './domina_rails/lib'
require 'domina_rails/database'


config = YAML.load_file("config/database.yml")["test"]
DominaRails::Database.create_db config
DominaRails::System.execute_cmd! "cat db/structure.sql | psql "
