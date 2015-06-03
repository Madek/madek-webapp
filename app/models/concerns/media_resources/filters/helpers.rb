module Concerns
  module MediaResources
    module Filters
      module Helpers
        extend ActiveSupport::Concern

        include Concerns::QueryHelpers
        include Concerns::MediaResources::Filters::MetaDataTypes
        include Concerns::MediaResources::Filters::MetaKeys

        module ClassMethods
          def filter_by_meta_datum(meta_key, value, type)
            result = if value == 'none'
                       filter_by_not_meta_key(meta_key)
                     elsif meta_key == 'any'
                       filter_by_meta_key
                     else
                       filter_by_meta_key(meta_key)
                     end
            result.filter_by_meta_datum_type(value, type)
          end
        end
      end
    end
  end
end
