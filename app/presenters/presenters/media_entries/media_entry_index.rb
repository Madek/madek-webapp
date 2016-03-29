module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::MediaEntries::Modules::MediaEntryPreviews

      def image_url
        img = preview_helper(type: :image, size: :medium)
        img.present? ? img.url : generic_thumbnail_url
      end

      def keywords_pretty
        @app_resource.keywords.map(&:to_s).join(', ')
      end

      def authors_pretty
        authors = @app_resource.meta_data.find_by(
          meta_key_id: 'madek_core:authors')
        authors ? authors.value.map(&:to_s).join(', ') : ''
      end

      def subtitle
        meta_data = @app_resource.meta_data.where(
          meta_key_id: 'madek_core:subtitle')
        meta_data.length > 0 ? meta_data[0].string : ''
      end
    end
  end
end
