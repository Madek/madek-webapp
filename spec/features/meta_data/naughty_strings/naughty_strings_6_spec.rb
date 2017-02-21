require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require Rails.root.join 'spec',
                        'features',
                        'shared',
                        'naughty_strings.rb'

feature 'Resource: MetaDatum' do
  it_handles_properly '"naughty strings"', 101..120
end
