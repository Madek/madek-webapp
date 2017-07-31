module Presenters
  module Explore
    module Modules
      module KeywordsForMetaKey

        private

        def keywords_for_meta_key_and_visible_entries(user, meta_key)
          Keyword.with_usage_count
            .where(meta_key: meta_key)
            .joins('INNER JOIN meta_data ' \
                   'ON meta_data.id = meta_data_keywords.meta_datum_id')
            .where(
              meta_data: {
                media_entry_id: \
                  auth_policy_scope(user, MediaEntry).joins(:media_file)
              }
            )
        end
      end
    end
  end
end
