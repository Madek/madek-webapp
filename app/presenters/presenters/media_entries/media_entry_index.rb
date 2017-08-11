module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      delegate_to_app_resource :subtitle

      def image_url
        size = :medium
        imgs = self.media_file.try(:previews)
          .try(:fetch, :images, nil)
        img = imgs.try(:fetch, size, nil) || imgs.try(:values).try(:first)
        img.url if img.present?
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
    end
  end
end
