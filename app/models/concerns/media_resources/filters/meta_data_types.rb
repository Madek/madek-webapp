module Concerns
  module MediaResources
    module Filters
      module MetaDataTypes
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::MetaData::Actors
        include Concerns::MediaResources::Filters::MetaData::Keywords
        include Concerns::MediaResources::Filters::MetaData::License
        include Concerns::MediaResources::Filters::MetaData::Primitive

        included do
          scope :filter_by_meta_datum_type, lambda { |meta_key, type, value|
            # Example: MetaDatum::Users -> filter_by_meta_datum_users
            filter_method = "filter_by_#{type.delete('::').underscore}".to_sym
            send(filter_method, meta_key, value)
          }
          private_class_method :filter_by_meta_datum_type
        end
      end
    end
  end
end
