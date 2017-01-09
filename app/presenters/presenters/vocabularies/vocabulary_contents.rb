module Presenters
  module Vocabularies
    class VocabularyContents < Presenter

      def initialize(vocabulary, user, list_conf, resources_type)
        @vocabulary = vocabulary
        @user = user
        @list_conf = list_conf
        @resources_type = resources_type
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@vocabulary, user: @user)
      end

      def resources
        type = @resources_type ? @resources_type : 'all'

        meta_key_ids = @vocabulary.meta_keys.map &:id

        user_scope =
          if type == 'entries'
            entries_scope(meta_key_ids)
          elsif type == 'collections'
            collections_scope(meta_key_ids)
          elsif type == 'all'
            all_scope(meta_key_ids)
          else
            raise Errors::InvalidParameterValue, "Type is #{type}"
          end

        Presenters::Shared::MediaResource::MediaResources.new(
          user_scope, @user, can_filter: false, list_conf: @list_conf
        )
      end

      private

      def entries_scope(meta_key_ids)
        scope = MediaEntry.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids }).distinct
        MediaEntryPolicy::Scope.new(@user, scope).resolve
      end

      def collections_scope(meta_key_ids)
        scope = Collection.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids }).distinct
        CollectionPolicy::Scope.new(@user, scope).resolve
      end

      def all_scope(meta_key_ids)
        media_entries = MediaEntry.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids })
        collections = Collection.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids })

        media_resources = MediaResource.where(
          "vw_media_resources.id IN (#{media_entries.select(:id).to_sql}) " \
          "OR vw_media_resources.id IN (#{collections.select(:id).to_sql}) ")
          .distinct

        Presenter::Shared::MediaResources::MediaResourcePolicy::Scope.new(
          @user, media_resources).resolve
      end
    end
  end
end
