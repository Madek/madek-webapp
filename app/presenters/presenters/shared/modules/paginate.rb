module Presenters
  module Shared
    module Modules
      module Paginate
        extend ActiveSupport::Concern

        included do

          private

          def paginate(resources, page)
            page > 0 ? resources.page(page) : resources
          end
        end
      end
    end
  end
end
