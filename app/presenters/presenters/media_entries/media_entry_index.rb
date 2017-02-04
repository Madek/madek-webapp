module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def image_url
        size = :medium
        imgs = self.media_file.try(:previews)
          .try(:fetch, :images, nil)
        img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
        img.url if img.present?
      end

      def keywords_pretty
        @app_resource.keywords.map(&:to_s).join(', ')
      end

      def subtitle
        meta_data = @app_resource.meta_data.where(
          meta_key_id: 'madek_core:subtitle')
        !meta_data.empty? ? meta_data[0].string : ''
      end

    end
  end
end
