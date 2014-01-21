#!/usr/bin/env ruby
require 'yaml'
require 'securerandom'

raise "env DOMINA_TRIAL_ID must be set" unless ENV['DOMINA_TRIAL_ID'] 
raise "env DOMINA_EXECUTION_ID ust be set" unless ENV['DOMINA_EXECUTION_ID'] 

def trial_id
  @_trial_id ||= (ENV['DOMINA_TRIAL_ID'][0..7])
end

def execution_id
  @_execution_id ||= (ENV['DOMINA_EXECUTION_ID'])[0..7]
end

config = YAML.load_file("config/database_domina.yml")
config["test"]["database"] = %Q[#{config["test"]["database"]}_#{trial_id}]
config["personas"]["database"] = %Q[#{config["personas"]["database"]}_#{execution_id}]

File.delete "config/database.yml" rescue nil
File.open("config/database.yml",'w'){|f| f.write(config.to_yaml)}
