#!/usr/bin/env ruby
require 'yaml'
require 'pry'

$LOAD_PATH << './domina/lib'
require 'domina/database'
require 'domina/system'

config = YAML.load_file("config/database.yml")["personas"]
Domina::Database.create_db config
Domina::System.execute_cmd! "cat db/empty_medienarchiv_instance_with_personas.pgsql.gz | gunzip | psql "
