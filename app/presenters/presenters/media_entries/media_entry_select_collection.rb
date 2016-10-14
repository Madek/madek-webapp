module Presenters
  module MediaEntries
    class MediaEntrySelectCollection < Presenters::Shared::AppResource

      include Presenters::Shared::MediaResource::Modules::PrivacyStatus
      include Presenters::Shared::Modules::SelectCollection

      def add_remove_collection_url
        add_remove_collection_media_entry_path(@app_resource)
      end

      def select_collection_url
        select_collection_media_entry_path(@app_resource)
      end

      def resource_url
        media_entry_path(@app_resource)
      end

    end
  end
end
