module Presenters
  module Collections
    class CollectionEditCover < Presenters::Collections::CollectionShow

      attr_reader :media_entries_presenter

      def initialize(user, collection, user_scopes, resource_list_params)
        super(collection, user, user_scopes, list_conf: resource_list_params)

        @media_entries_presenter =
          Presenters::Collections::ChildMediaResources.new(
            @app_resource.child_media_resources,
            user,
            list_conf: resource_list_params)
      end

      def submit_url
        update_cover_collection_path(@app_resource)
      end

      def cover_id
        @app_resource.cover ? @app_resource.cover.id : nil
      end

      def cancel_url
        collection_path(@app_resource)
      end

    end
  end
end
