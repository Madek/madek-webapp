module Presenters
  module Shared
    module Modules
      module Paginate
        extend ActiveSupport::Concern

        included do

          private

          def paginate(resources, page, per)
            page > 0 ? resources.page(page).per(per) : resources
          end
        end
      end
    end
  end
end
