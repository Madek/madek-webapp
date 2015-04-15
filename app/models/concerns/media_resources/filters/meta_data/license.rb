module Concerns
  module MediaResources
    module Filters
      module MetaData
        module License
          extend ActiveSupport::Concern
          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            scope :filter_by_meta_datum_license, lambda { |meta_key_id, id|
              filter_by_meta_key(meta_key_id).where(meta_data: { license_id: id })
            }
            private_class_method :filter_by_meta_datum_license
          end
        end
      end
    end
  end
end
