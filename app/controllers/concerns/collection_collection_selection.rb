module Concerns
  module CollectionCollectionSelection
    include Concerns::CollectionSelection

    def presenter_canonical_name
      'Presenters::Collections::CollectionSelectCollection'
    end

    def template_path
      'collections/select_collection'
    end

    def child_resources(collection)
      collection.collections
    end

    def success_message_key
      'collection_select_collection_flash_result'
    end

    def redirect_to_resource_path(resource)
      collection_path(resource)
    end

    def user_scopes_for_resource(resource)
      user_scopes_for_collection(resource)
    end
  end
end
