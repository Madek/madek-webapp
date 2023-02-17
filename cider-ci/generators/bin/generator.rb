require 'pry'
require 'yaml'
require 'pathname'
require 'active_support/all'

PROJECT_DIR = Pathname.new(__FILE__).expand_path.join("../../../..")

$ci_groups = {
  custom_path: {},
  embed: {},
  error_support: {},
  plain: {}, 
  session_expiration: {},}

def build_item(example)
  {name: example.id,
   description: example.metadata[:full_description],
   environment_variables: {
     RSPEC_NAME: example.metadata[:location],
     RSPEC_TEST: example.id }}
end

RSpec.configure do |config|
  config.around :each do |example| 
    metadata = example.metadata
    data = build_item(example)
    case metadata[:ci_group]
    when nil 
      $ci_groups[:plain].merge!({example.id => data})
    else
      raise "#{metadata[:ci_group]} is not known" unless metadata[:ci_group]
      $ci_groups[metadata[:ci_group]].merge!({example.id => data})
    end
  end
  config.after :all do 
    $ci_groups.each do |k,v|
      IO.write(PROJECT_DIR.join(
        "cider-ci","generators","#{k}_features.yml"),
        v.deep_stringify_keys.sort.to_h.to_yaml)
    end
  end
end
