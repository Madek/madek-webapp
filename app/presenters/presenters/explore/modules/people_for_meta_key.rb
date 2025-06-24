module Presenters
  module Explore
    module Modules
      module PeopleForMetaKey

        private

        def people_for_meta_key_and_visible_entries(user, meta_key)
          stats_query = MetaDatum::Person
            .joins(:meta_datum)
            .where(meta_data: {
              meta_key: meta_key,
              media_entry_id: auth_policy_scope(user, MediaEntry).reorder(nil)
            })
            .group(:person_id)
            .select('meta_data_people.person_id, COUNT(*) AS usage_count')
            .reorder(nil)
            
          Person
            .select("people.*, stats.usage_count")
            .joins("JOIN (#{stats_query.to_sql}) AS stats ON people.id = stats.person_id")
            .reorder('usage_count DESC')
        end
      end
    end
  end
end
