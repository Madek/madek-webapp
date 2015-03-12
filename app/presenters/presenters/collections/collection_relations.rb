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
          media_entries:
            @app_resource.media_entries
              .map { |c| Presenters::MediaEntries::MediaEntryIndex.new(c, @user) },
          collections:
            @app_resource.collections
              .map { |c| Presenters::Collections::CollectionIndex.new(c, @user) },
          filter_sets: \
            @app_resource.filter_sets
              .map { |c| Presenters::FilterSets::FilterSetIndex.new(c, @user) }
      end
    end
  end
end
