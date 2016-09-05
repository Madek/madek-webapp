module Modules
  module Keywords
    module SortByMatchRelevance
      def sort_by_match_relevance(presenter_dumps)
        presenter_dumps.sort do |p1, p2|
          t1 = p1[:label]
          t2 = p2[:label]
          string = params[:search_term]

          case_sensitive_full_match(string, t1, t2) or \
            case_insensitive_full_match(string, t1, t2) or \
            term_beginning_with_string(string, t1, t2) or \
            position_of_string_inside_of_term(string, t1, t2)
        end
      end

      def case_sensitive_full_match(string, t1, t2)
        if t1 == string and not t2 == string
          -1
        elsif t1 == string and t2 == string
          0
        elsif not t1 == string and t2 == string
          1
        end
      end

      def case_insensitive_full_match(string, t1, t2)
        if t1 =~ /^#{string}$/i and not t2 =~ /^#{string}$/i
          -1
        elsif t1 =~ /^#{string}$/i and t2 =~ /^#{string}$/i
          0
        elsif not t1 =~ /^#{string}$/i and t2 =~ /^#{string}$/i
          1
        end
      end

      def term_beginning_with_string(string, t1, t2)
        if t1.starts_with?(string) and not t2.starts_with?(string)
          -1
        elsif t1.starts_with?(string) and t2.starts_with?(string)
          0
        elsif not t1.starts_with?(string) and t2.starts_with?(string)
          1
        end
      end

      def position_of_string_inside_of_term(string, t1, t2)
        result = (t1 =~ /#{string}/i) - (t2 =~ /#{string}/i)
        if result == 0
          t1 <=> t2
        else
          result
        end
      end
    end
  end
end
