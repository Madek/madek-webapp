module Concerns
  module QueryIntersect
    extend ActiveSupport::Concern

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
