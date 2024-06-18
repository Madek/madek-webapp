module Presenters
  module Explore
    module Modules
      module NewestEntryWithImage

        private

        def newest_media_entry_with_image_file_for_keyword_and_user(
          keyword_id, user)

          auth_policy_scope(user, MediaEntry)
            .distinct
            .joins(:media_file)
            .joins('INNER JOIN previews ON previews.media_file_id = media_files.id')
            .joins(:meta_data)
            .joins('INNER JOIN meta_data_keywords ' \
                   'ON meta_data.id = meta_data_keywords.meta_datum_id')
            .where(meta_data: { type: 'MetaDatum::Keywords' })
            .where(meta_data_keywords: { keyword_id: keyword_id })
            .where(previews: { media_type: 'image' })
            .reorder('media_entries.created_at DESC')
            .limit(24)
        end

        def newest_media_entry_with_image_file_for_person_and_user(
          person_id, user)

          auth_policy_scope(user, MediaEntry)
            .distinct
            .joins(:media_file)
            .joins('INNER JOIN previews ON previews.media_file_id = media_files.id')
            .joins(:meta_data)
            .joins('INNER JOIN meta_data_people ' \
                   'ON meta_data.id = meta_data_people.meta_datum_id')
            .where(meta_data_people: { person_id: person_id })
            .where(previews: { media_type: 'image' })
            .reorder('media_entries.created_at DESC')
            .limit(24)
        end

        def newest_media_entry_with_image_file_for_meta_key_and_user(
          meta_key_id, user)
  
          auth_policy_scope(user, MediaEntry)
            .distinct
            .joins(:media_file)
            .joins('INNER JOIN previews ON previews.media_file_id = media_files.id')
            .joins(:meta_data)
            .where(meta_data: { meta_key_id: meta_key_id })
            .where(previews: { media_type: 'image' })
            .reorder('media_entries.created_at DESC')
            .limit(24)
        end  
      end
    end
  end
end
