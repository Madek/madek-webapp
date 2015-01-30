module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::Resources::ResourcesShow

      def highlights_thumbs
        @resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me) }
      end

      def media_entries_thumbs
        @resource \
          .media_entries
          .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me) }
      end

      def collections_thumbs
        @resource \
          .collections
          .map { |c| Presenters::Collections::CollectionThumb.new(c) }
      end

      def filter_sets_thumbs
        @resource \
          .filter_sets
          .map { |fs| Presenters::FilterSets::FilterSetThumb.new(fs) }
      end

    end
  end
end
