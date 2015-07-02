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
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries
              .new(@user, @app_resource.media_entries),
          collections: \
            Presenters::Collections::Collections
              .new(@user, @app_resource.collections),
          filter_sets: \
            Presenters::FilterSets::FilterSets
              .new(@user, @app_resource.filter_sets)
        )
      end
    end
  end
end
