module Presenters
  module Collections
    class CollectionIndex < Presenters::Shared::MediaResource::MediaResourceIndex
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource, user, list_conf: nil, show_relations: false)
        super(app_resource, user)
        @show_relations = show_relations
        @list_conf = list_conf
        initialize_relations
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
