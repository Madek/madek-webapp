module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::MediaEntries::Modules::ImageUrlHelper

      delegate_to_app_resource :subtitle

      def image_url
        image_url_for_size(:medium)
      end

      def keywords_pretty
        (@app_resource.keywords || []).map(&:to_s).join(', ')
      end

      def list_meta_data_url
        list_meta_data_media_entry_path(@app_resource)
      end

      def set_primary_custom_url
        set_primary_custom_url_media_entry_path(@app_resource.id, @app_resource.id)
      end

      def custom_urls?
        !@app_resource.custom_urls.empty?
      end
    end
  end
end
