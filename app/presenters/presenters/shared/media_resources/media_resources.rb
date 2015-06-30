module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter

        # NOTE: for pagination conf, see </config/initializers/kaminari_config.rb>
        def initialize(user,
                       media_resources: MediaResource.all,
                       filter: {},
                       order: nil,
                       page: 1,      # <- `nil` always means 'first page'
                       per_page: 12) # <- default for this presenter

          @user = user
          @filter = filter
          @order = order
          @page = page.to_i
          @per_page = per_page.to_i

          @media_resources = select_and_paginate_media_resources(media_resources)
        end

        def media_resources
          @media_resources.map { |r| indexify r }
        end

        def any? # this is about the collection, does not regard pagination!
          @media_resources.total_count > 0
        end

        def empty?
          !self.any?
        end

        def pagination_info
          # Just proxy methods from the paginated collection.
          # This is done to avoid handing any AR to the views
          # (and sadly `Kaminari.paginate_array` does NOT scale)…
          Pojo.new(
            total_count:   @media_resources.total_count,
            current_page:  @media_resources.current_page,
            total_pages:   @media_resources.total_pages,
            previous_page: @media_resources.prev_page,
            next_page:     @media_resources.next_page
          )
        end

        private

        def select_and_paginate_media_resources(media_resources)
          media_resources
            .viewable_by_user_or_public(@user)
            .filter(@filter)
            .reorder(@order)
            .page(@page)
            .per(@per_page)
        end

        def indexify(resource)
          case resource.class.name
          when 'MediaEntry'
            Presenters::MediaEntries::MediaEntryIndex.new \
              MediaEntry.find(resource.id),
              @user
          when 'Collection'
            Presenters::Collections::CollectionIndex.new \
              Collection.find(resource.id),
              @user
          when 'FilterSet'
            Presenters::FilterSets::FilterSetIndex.new \
              FilterSet.find(resource.id),
              @user
          else
            raise 'Unknown resource type!'
          end
        end
      end
    end
  end
end
