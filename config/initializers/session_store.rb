# Be sure to restart your server when you modify this file.

Rails.application.reloader.to_prepare do
  Madek::Application.config.session_store :cookie_store,
    key: Madek::Constants::Webapp::SESSION_NAME,
    httponly: true,
    secure: (Rails.env == 'production' && !Madek::Constants::MADEK_DISABLE_HTTPS)
end

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Madek::Application.config.session_store :active_record_store
