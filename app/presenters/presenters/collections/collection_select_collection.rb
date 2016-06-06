module Presenters
  module Collections
    class CollectionSelectCollection < \
      Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::Shared::Modules::SelectCollection

      def add_remove_collection_url
        add_remove_collection_collection_path(@app_resource)
      end

      def select_collection_url
        select_collection_collection_path(@app_resource)
      end

      def resource_url
        collection_path(@app_resource)
      end
    end
  end
end
