module Presenters
  module MediaEntries
    class MediaEntryTeaserForLogin < Presenters::Shared::AppResource
      include Presenters::MediaEntries::Modules::ImageUrlHelper

      def initialize(media_entry)
        super(media_entry)
        @user = nil
      end

      def image_url
        return @_image_url unless @_image_url.nil?
        @_image_url = image_url_for_size(:large)
      end

      def url
        prepend_url_context media_entry_path(@app_resource)
      end
    end
  end
end
