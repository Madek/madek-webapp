module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter
        attr_reader :media_entries, :collections, :filter_sets

        def initialize(user, media_entries: [], collections: [], filter_sets: [])
          @media_entries = \
            media_entries.map \
              { |me| Presenters::MediaEntries::MediaEntryIndex.new(me, user) }
          @collections = \
            collections.map \
              { |c| Presenters::Collections::CollectionIndex.new(c, user) }
          @filter_sets = \
            filter_sets.map \
              { |fs| Presenters::FilterSets::FilterSetIndex.new(fs, user) }
        end
      end
    end
  end
end
