require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require Rails.root.join 'spec',
                        'features',
                        'shared',
                        'naughty_strings.rb'

feature 'Resource: MetaDatum' do
  pending 'it_handles_properly "naughty strings", 441..460' do
    fail '(!) "The quic\b\b\b\b\b\bk brown fo\a\a\a\a\a\a\a\a\a\a\ax... [Beeeep]'
  end
  # it_handles_properly '"naughty strings"', 441..460
end
