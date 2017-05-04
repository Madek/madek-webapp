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

        def entries_by_id
          @_entries_by_id ||= related_entries_by_shared_keywords
            .map do |dat|
              e = MediaEntry.find_by_id(dat['id'])
              [e.id, Presenters::MediaEntries::MediaEntryIndex.new(e, @user)] if e
          end.compact.to_h
        end

        def keywords_by_id
          @_keywords_by_id ||= common_keywords
            .map do |id|
              kw = Keyword.with_usage_count.where(id: id).first
              [id, Presenters::Keywords::KeywordCommon.new(kw)] if kw
            end.compact.to_h
        end

        def common_keywords
          @_common_keywords ||= related_entries_by_shared_keywords
            .map { |d| d['keyword_ids'].split(',') }.flatten
            .uniq
        end

        def entry_ids_by_rank
          @_entry_ids_by_rank ||= entries_by_id.keys
        end

        def entry_ids_by_shared_keywords
          related_entries_by_shared_keywords
            .group_by { |d| d['keyword_ids'].split(',').sort }
            .map do |k, v|
              { keyword_ids: k, entry_ids: v.map { |d| d['id'] } }
            end
        end

        private

        # HACK! (should be app_settings/vocabulary_config)
        def ignored_keywords
          @ignored_keywords ||= Keyword
            .where(meta_key_id: 'copyright:license').map(&:id)
        end

        def related_entries_by_shared_keywords
          if @_related_entries_by_shared_keywords
            return @_related_entries_by_shared_keywords
          end

          # NOTE: default scope/visibility filter copy/pasted from AR output
          # feature is currently only supported for logged in users,
          # so we don't have to handle the public case

          return unless @user.is_a?(User)
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
                AND meta_data_keywords.keyword_id NOT IN (
                  SELECT UNNEST('{#{ignored_keywords.join(',')}}'::uuid[])
                )
          )
          AND meta_data_keywords.meta_datum_id = meta_data.id
          AND meta_data.media_entry_id = media_entries.id

          -- not entry itself
          AND media_entries.id != '#{entry_id}'

          -- no drafts!
          AND media_entries.is_published = 't'

          -- viewability:
          AND ( ( (
              -- is public or mine
              media_entries.get_metadata_and_previews = 't'
              OR media_entries.responsible_user_id = '#{@user.id}' )
              --  or I have a permission
              OR EXISTS (
                SELECT 1
                FROM   media_entry_user_permissions
                WHERE  media_entry_user_permissions.media_entry_id = media_entries.id
                AND media_entry_user_permissions.get_metadata_and_previews = 't'
                AND media_entry_user_permissions.user_id = '#{@user.id}' )
              -- or one of my groups has a permission
              OR EXISTS (
                SELECT 1
                FROM media_entry_group_permissions
                INNER JOIN groups ON media_entry_group_permissions.group_id = groups.id
                INNER JOIN groups_users ON groups_users.group_id = groups.id
                WHERE  media_entry_group_permissions.media_entry_id = media_entries.id
                AND media_entry_group_permissions.get_metadata_and_previews = 't'
                AND groups_users.user_id = '#{@user.id}' )
          ) )

          GROUP BY media_entries.id
          ORDER BY keyword_count DESC
          LIMIT 100
          SQL

          @_related_entries_by_shared_keywords = \
            ActiveRecord::Base.connection.exec_query(query).to_hash
        end

        # NOTE: v2-style query was like this.
        # does not seem very useful - shows 1 line of resources PER KEYWORD,
        # often with the same entries in different lines.
        #
        # def related_entries_by_keyword
        #   # for all Keywords in MetaData of this Entry,
        #   # get all other Entries that have MetaData with this Keyword.
        #   all_kws = @app_resource
        #     .meta_data.where(type: 'MetaDatum::Keywords')
        #     .map(&:keywords).flatten.uniq
        #
        #   related_entries_by_keyword = all_kws.map do |kw|
        #       entries = MediaEntry
        #         .viewable_by_user_or_public(@user)
        #         .joins(
        #           'INNER JOIN meta_data '\
        #           'ON meta_data.media_entry_id = media_entries.id')
        #         .joins(
        #           'INNER JOIN meta_data_keywords '\
        #           'ON meta_data_keywords.meta_datum_id = meta_data.id')
        #         .joins(
        #           'INNER JOIN keywords '\
        #           'ON keywords.id = meta_data_keywords.keyword_id')
        #         .where(keywords: { id: kw.id })
        #
        #       {
        #         keyword: kw,
        #         usage_count: entries.count,
        #         scope: entries
        #       }
        #     end
        #
        #   # sort, limit, presenterify
        #   related_entries_by_keyword
        #     .sort_by { |d| 0 - d[:usage_count] }
        #     .first(12)
        #     .map do |dat|
        #       {
        #         keyword: Presenters::Keywords::KeywordIndex.new(dat[:keyword]),
        #         usage_count: dat[:usage_count],
        #         entries: Presenters::Shared::MediaResource::MediaResources.new(
        #           dat[:scope], @user, can_filter: false, list_conf: {})
        #       }
        #     end
        #
        # end

      end
    end
  end
end
