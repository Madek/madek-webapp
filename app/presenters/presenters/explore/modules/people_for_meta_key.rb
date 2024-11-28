module Presenters
  module Explore
    module Modules
      module PeopleForMetaKey

        private

        def people_for_meta_key_and_visible_entries(user, meta_key)
          Person
            .joins(:meta_data_people)
            .joins("INNER JOIN meta_data ON meta_data.id = meta_data_people.meta_datum_id")
            .where(meta_data: { meta_key_id: meta_key.id })
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
