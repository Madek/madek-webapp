module Concerns
  module Groups
    module Searches
      extend ActiveSupport::Concern

      included do
        scope :text_search, lambda{ |search_term|
          where('searchable ILIKE :search_term', search_term: "%#{search_term}%")
        }

        scope :text_rank_search, lambda{ |search_term|
          rank = text_search_rank :searchable, search_term
          select_groups_by_rank(rank)
        }

        scope :trgm_rank_search, lambda{ |search_term|
          rank = trgm_search_rank :searchable, search_term
          select_groups_by_rank(rank)
        }

        def self.select_groups_by_rank(rank)
          select("groups.*, #{rank} AS search_rank") \
            .where("#{rank} > 0.05") \
            .reorder('search_rank DESC')
        end
      end
    end
  end
end
