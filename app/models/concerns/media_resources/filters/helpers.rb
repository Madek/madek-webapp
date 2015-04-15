module Concerns
  module MediaResources
    module Filters
      module Helpers
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::MetaDataTypes

        module ClassMethods
          def join_query_strings_with_intersect(*query_strings)
            query_strings = query_strings.map do |query_string|
              wrap_string_in_round_brackets(query_string)
            end
            result_query = query_strings.join(' INTERSECT ')
            "#{wrap_string_in_round_brackets(result_query)} " \
            "AS #{model_name.plural}"
          end

          def wrap_string_in_round_brackets(string)
            '(' + string + ')'
          end
        end

        included do
          scope :filter_by_meta_datum, lambda { |meta_key, type, value|
            case value
            when 'any'
              filter_by_meta_key(meta_key)
            when 'none'
              filter_by_not_meta_key(meta_key)
            else
              filter_by_meta_datum_type(meta_key, type, value)
            end
          }

          private_class_method :join_query_strings_with_intersect,
                               :wrap_string_in_round_brackets
        end
      end
    end
  end
end
