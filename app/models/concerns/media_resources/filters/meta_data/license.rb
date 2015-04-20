module Concerns
  module MediaResources
    module Filters
      module MetaData
        module License
          extend ActiveSupport::Concern
          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            scope :filter_by_meta_datum_license, lambda { |id|
              joins(:meta_data).where(meta_data: { license_id: id })
            }
          end
        end
      end
    end
  end
end
