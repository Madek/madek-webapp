module Presenters
  module Explore
    module Modules
      module KeywordsForMetaKey

        private

        def keywords_for_meta_key_and_visible_entries(user, meta_key)
          stats_query = MetaDatum::Keyword
            .joins(:meta_datum)
            .where(meta_data: {
              meta_key: meta_key,
              media_entry_id: auth_policy_scope(user, MediaEntry).reorder(nil)
            })
            .group(:keyword_id)
            .select('meta_data_keywords.keyword_id, COUNT(*) AS usage_count')
            .reorder(nil)
            
          Keyword
            .select("keywords.*, stats.usage_count")
            .joins("JOIN (#{stats_query.to_sql}) AS stats ON keywords.id = stats.keyword_id")
            .where(meta_key: meta_key)
            .reorder('usage_count DESC')
        end
      end
    end
  end
end
