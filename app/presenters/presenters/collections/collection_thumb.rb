module Presenters
  module Collections
    class CollectionThumb < Presenters::Shared::Resources::ResourcesThumb

      def image_url(size = :small)
        collection_image_path(@resource, size)
      end

    end
  end
end
