module Presenters
  module MediaEntries
    class MediaEntryThumb < Presenters::Shared::Resources::ResourcesThumb

      def image_url(size = :small)
        media_entry_image_path(@resource, size)
      end

      def authors
        @resource.meta_data.find_by(meta_key_id: 'author').to_s
      end

    end
  end
end
