module Presenters
  module MediaEntries
    class MediaEntryTeaserForExplore < Presenters::Shared::AppResource
      def initialize(media_entry)
        super(media_entry)
      end

      def title
        # PERF: try to get title from model
        @app_resource.title \
          || Presenters::MediaEntries::PresMediaEntry.new(@app_resource).title
      end

      def authors_pretty
        authors = @app_resource.meta_data
          .find_by(meta_key_id: 'madek_core:authors')
        authors ? authors.value.map(&:to_s).join(', ') : ''
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
