#!/usr/bin/env ruby
require 'yaml'
require 'pry'

$LOAD_PATH << './domina_rails/lib'
require 'domina_rails/database'
require 'domina_rails/system'

config = YAML.load_file("config/database.yml")["personas"]
DominaRails::Database.create_db config
DominaRails::System.execute_cmd! "cat db/empty_medienarchiv_instance_with_personas.pgsql.gz | gunzip | psql "
