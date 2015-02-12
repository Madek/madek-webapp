module Presenters
  module Collections
    class CollectionThumb < Presenters::Shared::Resources::ResourcesThumb

      def url
        collection_path @resource
      end

      def image_url(size = :small)
        preview_collection_path(@resource, size)
      end

    end
  end
end
