# Be sure to restart your server when you modify this file.

# NOTE: intentionally NOT Madek::Constants::Webapp::SESSION_NAME here - that
# file references ErrorsController/Settings and isn't autoload-safe this early
# in boot; the middleware stack can be built (and memoized) before a
# to_prepare/after_initialize block referencing it would run, silently
# leaving the app on Rails' auto-derived default cookie name instead (#870).
# Keep in sync with Madek::Constants::Webapp::SESSION_NAME.
Madek::Application.config.session_store :cookie_store,
  key: '_Madek_session',
  httponly: true,
  secure: (Rails.env == 'production' && !Madek::Constants::MADEK_DISABLE_HTTPS)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Madek::Application.config.session_store :active_record_store
