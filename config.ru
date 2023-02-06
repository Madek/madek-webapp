# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

if relative_url_root = Rails.application.config.relative_url_root.presence
  map relative_url_root do
    run Rails.application
    Rails.application.load_server
  end
else
  run Rails.application
end
