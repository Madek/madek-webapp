module Concerns
  module MediaEntryCollectionSelection
    include Concerns::CollectionSelection

    def presenter_canonical_name
      'Presenters::MediaEntries::MediaEntrySelectCollection'
    end

    def template_path
      'media_entries/select_collection'
    end

    def child_resources(collection)
      collection.media_entries
    end

    def success_message_key
      'media_entry_select_collection_flash_result'
    end

    def redirect_to_resource_path(resource)
      media_entry_path(resource)
    end

    def user_scopes_for_resource(resource)
      user_scopes_for_media_resource(resource)
    end

  end
end