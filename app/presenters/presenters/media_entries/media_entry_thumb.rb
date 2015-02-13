module Presenters
  module MediaEntries
    class MediaEntryThumb < Presenters::Shared::Resources::ResourcesThumb

      def url
        media_entry_path @resource
      end

      def image_url
        if @resource.media_file.represantable_as_image?
          preview_media_entry_path(@resource, :small)
        else
          generic_thumbnail_url
        end
      end

      def authors
        @resource.meta_data.find_by(meta_key_id: 'author').to_s
      end

    end
  end
end
