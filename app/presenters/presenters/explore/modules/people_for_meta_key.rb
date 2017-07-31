module Presenters
  module Explore
    module Modules
      module PeopleForMetaKey

        private

        def people_for_meta_key_and_visible_entries(user, meta_key)
          Person.with_usage_count
            .joins(meta_data: :meta_key)
            .where(meta_keys: { id: meta_key.id })
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
