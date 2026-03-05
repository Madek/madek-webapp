module Presenters
  module MediaEntries
    class MediaEntryTeaserForExplore < Presenters::Shared::AppResource
      include Presenters::MediaEntries::Modules::ImageUrlHelper

      def initialize(media_entry)
        super(media_entry)
        @user = nil
      end

      delegate_to_app_resource :title

      def authors_pretty
        @app_resource.authors || ''
      end

      def image_url
        image_url_for_size(:large)
      end

      def url
        prepend_url_context media_entry_path(@app_resource)
      end
    end
  end
end
