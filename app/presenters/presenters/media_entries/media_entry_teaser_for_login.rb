module Presenters
  module MediaEntries
    class MediaEntryTeaserForLogin < Presenters::Shared::AppResource
      def initialize(media_entry)
        super(media_entry)
        @media_file = \
          if @app_resource.try(:media_file).present?
            Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
          end
      end

      def image_url
        size = :medium
        img = @media_file.try(:previews)
          .try(:fetch, :images, nil)
          .try(:fetch, size, nil)
        img.url if img.present?
      end

      def url
        prepend_url_context media_entry_path(@app_resource)
      end
    end
  end
end
