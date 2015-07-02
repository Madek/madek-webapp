module Presenters
  module Shared
    module MediaResources
      class MediaResources < Presenter
        include Presenters::Shared::Concerns::PaginationInfo

        attr_reader :total_count, :resources, :pagination_info

        # NOTE: for pagination conf, see </config/initializers/kaminari_config.rb>
        def initialize(user,
                       resources = [],
                       filter: {},
                       order: nil,
                       page: 1, per_page: 12)

          @user = user
          @filter = filter
          @order = order
          @page = page.to_i # nil always means 'first page'
          @per_page = per_page.to_i # default for this presenter

          selected_resources = select(resources)
          @total_count = selected_resources.count
          @pagination_info = pojo_pagination_info(selected_resources)

          @resources = indexify(selected_resources)
        end

        def empty?
          total_count == 0
        end

        def any?
          not empty?
        end

        private

        def indexify_with_presenter(resources, index_presenter)
          resources.map { |r| index_presenter.new(r, @user) }
        end

        def select(resources)
          resources
            .viewable_by_user_or_public(@user)
            .filter(@filter)
            .reorder(@order)
            .page(@page)
            .per(@per_page)
        end
      end
    end
  end
end
