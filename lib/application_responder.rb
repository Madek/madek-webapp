class ApplicationResponder < ActionController::Responder
  # TODO: uncomment and refactor flash usage across app
  # include Responders::FlashResponder

  include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder

  # custom responders
  include Responders::YamlResponder
end
