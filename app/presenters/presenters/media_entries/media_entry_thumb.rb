module Presenters
  module MediaEntries
    class MediaEntryThumb < Presenters::Shared::Resources::ResourcesThumb
      include Presenters::MediaEntries::MediaEntryHelpers

      def url
        media_entry_path @resource
      end

      def image_url
        image_url_helper(:small)
      end

      def authors
        @resource.meta_data.find_by(meta_key_id: 'author').to_s
      end
    end
  end
end
