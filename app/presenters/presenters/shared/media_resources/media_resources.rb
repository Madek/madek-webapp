module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter

        # NOTE: for pagination conf, see </config/initializers/kaminari_config.rb>
        def initialize(user,
                       media_entries: nil, collections: nil, filter_sets: nil,
                       filter: {},
                       order: nil,
                       page: 1, per_page: 12)

          @user = user
          @filter = filter
          @order = order
          @page = (page || 1).to_i # nil always means 'first page'
          @per_page = (per_page || 12).to_i # default for this presenter

          @total_counts = {}
          @highest_total_count = 0
          @media_resources = {
            media_entries: init_by_type(:media_entries, media_entries,
                                        Presenters::MediaEntries::MediaEntryIndex),
            collections:   init_by_type(:collections, collections,
                                        Presenters::Collections::CollectionIndex),
            filter_sets:   init_by_type(:filter_sets, filter_sets,
                                        Presenters::FilterSets::FilterSetIndex)
          }
        end

        def media_entries
          @media_resources[:media_entries]
        end

        def collections
          @media_resources[:collections]
        end

        def filter_sets
          @media_resources[:filter_sets]
        end

        def empty?
          !@total_counts.values.any?
        end

        def total_counts
          counts = @total_counts.values.reject(&:nil?)
          OpenStruct.new(@total_counts
            .merge(highest: counts.max, total: counts.sum))
        end

        def pagination_info
          # do this manually because we're paginating multiple collections:
          total_pages = (total_counts.highest.to_f / @per_page.to_f).ceil
          OpenStruct.new(
            current_page: @page,
            total_pages: total_pages,
            previous_page: (@page > 1) ? (@page - 1) : false,
            next_page:     (@page < total_pages) ? (@page + 1) : false
          )
        end

        private

        def init_by_type(type, media_resources, index_presenter)
          resources = media_resources ? select_resources(media_resources) : []
          update_counts(type, resources) # just for the side-effects
          resources.map { |r| index_presenter.new(r, @user) }
        end

        def select_resources(resources)
          resources
            .viewable_by_user(@user)
            .filter(@filter)
            .reorder(@order)
            .page(@page)
            .per(@per_page)
        end

        def update_counts(type, ar_collection)
          count = ar_collection.try(:total_count)
          @total_counts[type] = count if count && count > 0
        end
      end
    end
  end
end
