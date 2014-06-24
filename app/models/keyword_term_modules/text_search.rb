module KeywordTermModules
  module TextSearch
    extend ActiveSupport::Concern

    included do

      scope :text_search, lambda{|search_term| basic_search({term: search_term},true)}

      scope :text_rank_search, lambda{|search_term| 
        rank= text_search_rank :term, search_term
        select("#{'keyword_terms.*,' if select_values.empty?}  #{rank} AS search_rank") \
          .where("#{rank} > 0.05") \
          .reorder("search_rank DESC") }

      scope :trgm_rank_search, lambda{|search_term| 
        rank= trgm_search_rank :term, search_term
        select("#{'keyword_terms.*,' if select_values.empty?} #{rank} AS search_rank") \
          .where("#{rank} > 0.05") \
          .reorder("search_rank DESC") }

    end
  end
end
