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
              default_rule(t1, t2)
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

      def default_rule(t1, t2)
        t1 <=> t2
      end
    end
  end
end
