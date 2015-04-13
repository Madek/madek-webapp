module Concerns
  module MediaResources
    module Filters
      module Filters
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::Helpers

        module ClassMethods
          def filter_by_meta_data(*meta_data)
            query_strings = meta_data.map do |meta_datum|
              raise 'Value can\'t be an array' if meta_datum[:value].is_a?(Array)
              type = \
                (meta_datum[:type] \
                 or MetaKey.find(meta_datum[:key]).meta_datum_object_type)
              filter_by_meta_datum(meta_datum[:key],
                                   type,
                                   meta_datum[:value]).to_sql
            end
            from \
              join_query_strings_with_intersect \
                *query_strings
          end
        end
      end
    end
  end
end
