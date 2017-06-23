class ApplicationResponder < ActionController::Responder
  # TODO: uncomment and refactor flash usage across app
  include Responders::FlashResponder

  include Responders::HttpCacheResponder

  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder

  # custom responders
  include Responders::YamlResponder
  include Responders::JsonResponder

  private

  def serialize_resource
    # NOTE: supports "sparse" request (to optimize async calls & debugging)
    if resource.is_a?(Presenter)
      resource.dump(sparse_spec: sparse_request_spec_from_param)
    else
      resource
    end
  end

  def sparse_request_spec_from_param
    begin
      param = request.params['___sparse']
      JSON.parse(param) if param
    rescue
      nil
    end
  end
end
