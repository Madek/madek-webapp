module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResources::MediaResourceRelations

      def any?
        super or
          child_media_resources.media_entries.any? or
          child_media_resources.collections.any? or
          child_media_resources.filter_sets.any?
      end

      def child_media_resources
        Presenters::Shared::MediaResources::MediaResources.new \
          @user,
          media_entries: @app_resource.media_entries,
          collections: @app_resource.collections,
          filter_sets: @app_resource.filter_sets
      end
    end
  end
end
