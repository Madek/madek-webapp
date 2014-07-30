module UserModules
  module TextSearch
    extend ActiveSupport::Concern

    # postgres' text doesn't split up email addresses; let's do it manually in a searchable field;
    # since we have searchable field, let's put all strings in there; searching is simpler and we need only one index 

    included do

      after_save :update_searchable
      after_save :update_trgm_searchable

      scope :text_search, lambda{|search_term| 
        where(%Q{users.searchable ILIKE :term}, term: "%#{search_term}%")}

      scope :text_rank_search, lambda{|search_term| 
        rank= text_search_rank :searchable, search_term
        select("#{'users.*,' if select_values.empty?}  #{rank} AS search_rank") \
          .where("#{rank} > 0.05") \
          .reorder("search_rank DESC") }

      scope :trgm_rank_search, lambda{|search_term| 
        rank= trgm_search_rank :trgm_searchable, search_term
        select("#{'users.*,' if select_values.empty?} #{rank} AS search_rank") \
          .where("#{rank} > 0.05") \
          .reorder("search_rank DESC") }

    end

    def convert_to_searchable str
      [str,str.gsub(/[^\w]/,' ').split(/\s+/)].flatten.sort.join(' ')
    end

    def update_searchable
      update_columns searchable: [convert_to_searchable(login),convert_to_searchable(email),
                                  person.last_name,person.first_name,person.pseudonym] \
                                  .flatten.compact.sort.uniq.join(" ")
    end

    def update_trgm_searchable
      update_columns trgm_searchable: [login,email,person.last_name,
                                       person.first_name,person.pseudonym] \
                                       .flatten.compact.sort.uniq.join(" ")
    end


  end
end

