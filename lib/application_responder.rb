class ApplicationResponder < ActionController::Responder
  # TODO: uncomment and refactor flash usage across app
  include Responders::FlashResponder

  # NOTE: we don't use this (only works with `#to_format`)
  # include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder

  # custom responders
  include Responders::YamlResponder
  include Responders::JsonResponder
end
