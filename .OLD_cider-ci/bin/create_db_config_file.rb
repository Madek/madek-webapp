#!/usr/bin/env ruby
require 'yaml'

raise 'env CIDER_CI_TRIAL_ID must be set' unless ENV['CIDER_CI_TRIAL_ID']
raise 'env CIDER_CI_EXECUTION_ID ust be set' unless ENV['CIDER_CI_EXECUTION_ID']

def trial_id
  @_trial_id ||= (ENV['CIDER_CI_TRIAL_ID'][0..7])
end

config = YAML.load_file('config/database_cider-ci_template.yml')
config['test']['database'] = %(#{config['test']['database']}_#{trial_id})
config['test']['username'] = ENV['PG93_USER']
config['test']['password'] = ENV['PG93_PASSWORD']
config['test']['port'] = ENV['PG93_PORT']

File.delete 'config/database.yml' rescue nil
File.open('config/database.yml', 'w') { |f| f.write(config.to_yaml) }
