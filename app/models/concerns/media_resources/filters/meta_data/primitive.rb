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
                    lambda { |meta_key_id, value|
                      filter_by_meta_key(meta_key_id)
                        .where(meta_data: { string: value })
                    }
              private_class_method method_name
            end
          end
        end
      end
    end
  end
end
