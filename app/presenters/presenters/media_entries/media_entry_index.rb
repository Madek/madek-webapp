module Presenters
  module MediaEntries
    class MediaEntryIndex < Presenters::Shared::MediaResources::MediaResourceIndex

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def url
        media_entry_path @app_resource
      end

      def image_url
        image_url_helper(:small)
      end

      def authors
        @app_resource.meta_data.find_by(meta_key_id: 'author').to_s
      end
    end
  end
end
