# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

if relative_url_root = Rails.application.config.relative_url_root.presence
  map relative_url_root do
    run Rails.application
  end
else
  run Rails.application
end
