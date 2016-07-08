module Presenters
  module MediaEntries
    class MediaEntryTeaserForExplore < Presenters::Shared::AppResource
      def initialize(media_entry)
        super(media_entry)
        @media_file = \
          if @app_resource.try(:media_file).present?
            Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
          end
      end

      def title
        @app_resource.title
      end

      def authors_pretty
        authors = @app_resource.meta_data.find_by(
          meta_key_id: 'madek_core:authors')
        authors ? authors.value.map(&:to_s).join(', ') : ''
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
