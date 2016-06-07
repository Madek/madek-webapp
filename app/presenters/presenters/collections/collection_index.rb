module Presenters
  module Collections
    class CollectionIndex < Presenters::Shared::MediaResource::MediaResourceIndex
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource, user, list_conf: nil)
        super(app_resource, user)
        @list_conf = list_conf
      end

      private

      def parent_relation_resources
        @app_resource.parent_collections
      end

      def child_relation_resources
        @app_resource.child_media_resources
      end

    end
  end
end
