module Presenters
  module MediaEntries
    class MediaEntryTeaserForLogin < Presenters::Shared::AppResource
      def initialize(media_entry)
        super(media_entry)
      end

      def image_url
        return @_image_url unless @_image_url.nil?
        size = :large
        imgs = \
          if @app_resource.try(:media_file).present?
            Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
              .try(:previews).try(:fetch, :images, nil)
          end
        img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
        @_image_url = img.try(:url).try(:presence)
        @_image_url
      end

      def url
        prepend_url_context media_entry_path(@app_resource)
      end
    end
  end
end
