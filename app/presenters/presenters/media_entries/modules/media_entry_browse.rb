
module Presenters
  module MediaEntries
    module Modules
      class MediaEntryBrowse < Presenters::Shared::AppResource

        # > Und das Ergebnis dieser Betrachtung lautet nun:
        # > Wir sehen ein kompliziertes Netz von Ähnlichkeiten,
        # > die einander übergreifen und kreuzen.
        # > Ähnlichkeiten im Großen und Kleinen.
        # >
        # > — Ludwig Wittgenstein, Philosophische Untersuchungen, §66

        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        # this is the main result, details are in the other maps (db-style)
        def entry_ids_by_shared_keywords
          related_entries_by_shared_keywords
            .group_by { |d| d['keyword_ids'].split(',').sort }
            .map do |k, v|
              { keyword_ids: k, entry_ids: v.map { |d| d['id'] } }
            end
        end

        def keywords_by_id
          @_keywords_by_id ||= related_entries_by_shared_keywords
            .map { |d| d['keyword_ids'].split(',') }
            .flatten.uniq
            .map do |id|
              [id, Presenters::Keywords::KeywordIndex.new(Keyword.find(id))]
            end.compact.to_h
        end

        def meta_keys_by_id
          @_meta_keys_by_id ||= keywords_by_id
            .values.map(&:meta_key_id).flatten.uniq
            .map do |id|
              [id, Presenters::MetaKeys::MetaKeyCommon.new(MetaKey.find(id))]
            end.to_h
        end

        def vocabularies_by_id
          @_vocabularies_by_id ||= meta_keys_by_id
            .values.map(&:vocabulary_id).flatten.uniq
            .map do |id|
              voc = Vocabulary.find(id)
              [id, Presenters::Vocabularies::VocabularyCommon.new(voc)]
            end.to_h
        end

        # PERF: only dump needed data (only `image_url`, `url`!)
        def entries_by_id
          @_entries_by_id ||= related_entries_by_shared_keywords
            .map do |dat|
          wanted_props = %i(uuid url image_url media_type)
          e = MediaEntry.find_by_id(dat['id'])
          raise ActiveRecord::RecordNotFound unless e
          p = Presenters::MediaEntries::MediaEntryIndex.new(e, @user)
          [e.id, p.dump(sparse_spec: wanted_props.map { |k| [k, {}] }.to_h)]
          end.to_h
        end

        def filter_search_path
          prepend_url_context(media_entries_path)
        end

        private

        def ignored_keywords
          return @_ignored_keywords if @_ignored_keywords
          mks = AppSetting.first.ignored_keyword_keys_for_browsing || []
          @_ignored_keywords = Keyword.where(meta_key: mks).pluck(:id)
        end

        def related_entries_by_shared_keywords
          if @_related_entries_by_shared_keywords
            return @_related_entries_by_shared_keywords
          end

          entry_id = @app_resource.id

          query = <<-SQL
          SELECT
            media_entries.id,
            string_agg(meta_data_keywords.keyword_id::"varchar", ',') AS keyword_ids,
            count(*) AS keyword_count
          FROM meta_data_keywords, meta_data, media_entries

          -- find common keywords
          WHERE meta_data_keywords.keyword_id IN (
              SELECT DISTINCT meta_data_keywords.keyword_id
              FROM meta_data_keywords, meta_data
              WHERE
                meta_data.media_entry_id = '#{entry_id}'
                AND meta_data_keywords.meta_datum_id = meta_data.id
                #{ignored_keywords_subquery}
          )
          AND meta_data_keywords.meta_datum_id = meta_data.id
          AND meta_data.media_entry_id = media_entries.id

          -- not entry itself
          AND media_entries.id != '#{entry_id}'

          -- no drafts!
          AND media_entries.is_published = 't'

          -- viewability:
          AND ( #{subquery_visibility} )

          GROUP BY media_entries.id
          ORDER BY keyword_count DESC
          LIMIT 100
          SQL

          @_related_entries_by_shared_keywords = \
            ActiveRecord::Base.connection.exec_query(query).to_hash
        end

        def ignored_keywords_subquery
          if ignored_keywords.any?
            <<-SQL
              AND meta_data_keywords.keyword_id NOT IN (
                SELECT UNNEST('{#{ignored_keywords.join(',')}}'::uuid[])
              )
            SQL
          end
        end

        def subquery_visibility(user = @user)
          unless user.present?
            <<-SQL
              media_entries.get_metadata_and_previews = 't'
            SQL
          else
            <<-SQL
              ( (
                  -- is public or mine
                  media_entries.get_metadata_and_previews = 't'
                  OR media_entries.responsible_user_id = '#{user.id}' )
                  --  or I have a permission
                  OR EXISTS (
                    SELECT 1
                    FROM   media_entry_user_permissions
                    WHERE  media_entry_user_permissions.media_entry_id = media_entries.id
                    AND media_entry_user_permissions.get_metadata_and_previews = 't'
                    AND media_entry_user_permissions.user_id = '#{user.id}' )
                  -- or one of my groups has a permission
                  OR EXISTS (
                    SELECT 1
                    FROM media_entry_group_permissions
                    INNER JOIN groups ON media_entry_group_permissions.group_id = groups.id
                    INNER JOIN groups_users ON groups_users.group_id = groups.id
                    WHERE  media_entry_group_permissions.media_entry_id = media_entries.id
                    AND media_entry_group_permissions.get_metadata_and_previews = 't'
                    AND groups_users.user_id = '#{user.id}' )
              )
            SQL
          end
        end

      end
    end
  end
end
