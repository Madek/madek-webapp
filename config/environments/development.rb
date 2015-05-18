Madek::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # With this cache store, all fetch and read operations will result in a miss.
  config.cache_store = :null_store

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Always show the developer-friendly error pages in DEV, even from non-localhost:
  config.consider_all_requests_local = false
  #       ^ set to 'false' to force showing of custom error pages in DEV

  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

end
