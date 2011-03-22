Cucumber::Rails::World.use_transactional_fixtures = false

# http://freelancing-god.github.com/ts/en/testing.html
require 'cucumber/thinking_sphinx/external_world'

# Monkeypatch thinking sphinx init in order to NOT overwrite
# the config - otherwise all our custom changes to the config
# are lost! See:
# http://groups.google.com/group/thinking-sphinx/browse_thread/thread/70dd3a663c3b9792#
class ThinkingSphinx::Test
  def self.start
    config.controller.index
    config.controller.start
  end
end

Cucumber::ThinkingSphinx::ExternalWorld.new
