module Presenters
  module Shared
    module Concerns
      module PaginationInfo
        extend ActiveSupport::Concern

        included do

          private

          def pojo_pagination_info(resources)
            Pojo.new(
              current_page: resources.current_page,
              total_pages: resources.total_pages,
              previous_page: resources.prev_page,
              next_page: resources.next_page,
              on_first_page: resources.first_page?,
              on_last_page: resources.last_page?,
              total_count: resources.total_count
            )
          end
        end
      end
    end
  end
end
