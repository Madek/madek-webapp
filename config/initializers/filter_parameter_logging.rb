# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :crypt, :salt, :certificate, :otp, :ssn
]

# Custom filter: "*_key*", but not "meta_key_id"
Rails.application.config.filter_parameters += [
  ->(key, value) {
    value.replace('[FILTERED]') if key.to_s.include?('_key') && key != 'meta_key_id'
  }
]
