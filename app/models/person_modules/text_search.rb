module PersonModules
  module TextSearch
    extend ActiveSupport::Concern

    included do
      after_save :update_searchable

      after_save do
        if user
          user.update_searchable
          user.update_trgm_searchable
        end
      end

      def update_searchable
        update_columns searchable: [last_name,first_name,pseudonym].flatten \
          .compact.sort.uniq.join(" ")
      end


      # NOTE: this is an old implementation; it doesn't use pg text search features
      # and it is slow, too
      scope :search, lambda { |query|
        return scoped if query.blank?
        q = query.split.map{|s| "%#{s}%"}
        where(arel_table[:first_name].matches_any(q).
              or(arel_table[:last_name].matches_any(q)).
              or(arel_table[:pseudonym].matches_any(q))) }

      scope :text_search, lambda{|search_term| basic_search({searchable: search_term},true)}

      scope :text_rank_search, lambda{|search_term| 
        rank= text_search_rank :searchable, search_term
        select("#{'people.*,' if select_values.empty?}  #{rank} AS search_rank") \
          .where("#{rank} > 0.05") \
          .reorder("search_rank DESC") }

      scope :trgm_rank_search, lambda{|search_term| 
        rank= trgm_search_rank :searchable, search_term
        select("#{'people.*,' if select_values.empty?} #{rank} AS search_rank") \
          .where("#{rank} > 0.05") \
          .reorder("search_rank DESC") }

    end
  end
end


