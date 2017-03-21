module Presenters
  module MediaEntries
    class MediaEntryTeaserForExplore < Presenters::Shared::AppResource
      def initialize(media_entry)
        super(media_entry)
      end

      delegate_to_app_resource :title

      def authors_pretty
        @app_resource.authors || ''
      end

      def image_url
        size = :large
        imgs = \
          if @app_resource.try(:media_file).present?
            Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
              .try(:previews).try(:fetch, :images, nil)
          end
        img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
        img.url if img.present?
      end

      def url
        prepend_url_context media_entry_path(@app_resource)
      end
    end
  end
end
