module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter
        attr_reader :media_entries, :collections, :filter_sets

        def initialize(user,
                       media_entries: nil,
                       collections: nil,
                       filter_sets: nil,
                       order: nil,
                       page: 1,
                       per: nil)
          @user = user
          @order = order
          @page = page
          @per = per
          initialize_media_entries(media_entries)
          initialize_collections(collections)
          initialize_filter_sets(filter_sets)
        end

        private

        def initialize_media_entries(media_entries)
          if media_entries
            @media_entries = \
              handle_resources(media_entries,
                               Presenters::MediaEntries::MediaEntryIndex)
          end
          @media_entries ||= []
        end

        def initialize_collections(collections)
          if collections
            @collections = \
              handle_resources(collections,
                               Presenters::Collections::CollectionIndex)
          end
          @collections ||= []
        end

        def initialize_filter_sets(filter_sets)
          if filter_sets
            @filter_sets = \
              handle_resources(filter_sets,
                               Presenters::FilterSets::FilterSetIndex)
          end
          @filter_sets ||= []
        end

        def handle_resources(resources, index_presenter)
          resources
            .viewable_by_user(@user)
            .reorder(@order)
            .page(@page)
            .per(@per)
            .map { |r| index_presenter.new(r, @user) }
        end
      end
    end
  end
end
