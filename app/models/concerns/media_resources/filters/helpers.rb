module Concerns
  module MediaResources
    module Filters
      module Helpers
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::MetaData::Actors
        include Concerns::MediaResources::Filters::MetaData::Keywords
        include Concerns::MediaResources::Filters::MetaData::License

        included do
          scope :filter_by_meta_datum, lambda { |meta_key, type, value|
            case type
            when 'MetaDatum::Keywords'
              filter_by_meta_datum_type_keywords(meta_key, value)
            when 'MetaDatum::People'
              filter_by_meta_datum_type_people(meta_key, value)
            when 'MetaDatum::Users'
              filter_by_meta_datum_type_users(meta_key, value)
            when 'MetaDatum::Groups'
              filter_by_meta_datum_type_groups(meta_key, value)
            when 'MetaDatum::License'
              filter_by_meta_datum_type_license(meta_key, value)
            when 'MetaDatum::Text', 'MetaDatum::TextDate'
              filter_by_meta_key(meta_key)
                .where(meta_data: { string: value })
            else
              raise 'Unknown meta data type'
            end
          }
        end

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
      end
    end
  end
end
