module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Primitive
          extend ActiveSupport::Concern

          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            %w(text text_date).each do |primitive_type|
              method_name =  "filter_by_meta_datum_#{primitive_type}".to_sym
              scope method_name,
                    lambda { |value|
                      joins(:meta_data)
                        .where(meta_data: { string: value })
                    }
            end
          end
        end
      end
    end
  end
end
