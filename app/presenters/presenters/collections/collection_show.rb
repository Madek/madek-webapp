module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::Resources::ResourceShow

      def highlights_polythumbs
        @resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryPolyThumb.new(me) }
      end

      def media_entries_polythumbs
        @resource \
          .media_entries
          .map { |me| Presenters::MediaEntries::MediaEntryPolyThumb.new(me) }
      end

      def collections_polythumbs
        @resource \
          .collections
          .map { |c| Presenters::Collections::CollectionPolyThumb.new(c) }
      end

      def filter_sets_polythumbs
        @resource \
          .filter_sets
          .map { |fs| Presenters::FilterSets::FilterSetPolyThumb.new(fs) }
      end

    end
  end
end
