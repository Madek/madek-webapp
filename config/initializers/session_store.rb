# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

Madek::Application.config.session_store :cookie_store,
  key: '_Madek_session',
  httponly: true,
  secure: (Rails.env == 'production' && !Madek::Constants::MADEK_DISABLE_HTTPS)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Madek::Application.config.session_store :active_record_store
