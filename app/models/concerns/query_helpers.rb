module Concerns
  module QueryHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      def join_query_strings_with_union(*query_strings)
        join_query_strings(:union, *query_strings)
      end

      def join_query_strings_with_intersect(*query_strings)
        join_query_strings(:union, *query_strings)
      end

      def join_query_strings(set_op, *query_strings)
        query_strings = query_strings.compact.map do |query_string|
          wrap_string_in_round_brackets(query_string)
        end
        result_query = query_strings.join(" #{set_op.upcase} ")
        "#{wrap_string_in_round_brackets(result_query)} " \
        "AS #{model_name.plural}"
      end

      def wrap_string_in_round_brackets(string)
        '(' + string + ')'
      end
    end
  end
end
