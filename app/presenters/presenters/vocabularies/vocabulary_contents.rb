module Presenters
  module Vocabularies
    class VocabularyContents < Presenter
      include AuthorizationSetup

      def initialize(vocabulary, user, list_conf, resources_type, sub_filters)
        @vocabulary = vocabulary
        @user = user
        @list_conf = list_conf
        @resources_type = resources_type
        @sub_filters = sub_filters
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@vocabulary, user: @user)
      end

      def resources
        type = @resources_type ? @resources_type : 'entries'

        meta_key_ids = @vocabulary.meta_keys.map &:id

        user_scope =
          if type == 'entries'
            entries_scope(meta_key_ids)
          elsif type == 'collections'
            collections_scope(meta_key_ids)
          # elsif type == 'all'
          #   all_scope(meta_key_ids)
          else
            raise Errors::InvalidParameterValue, "Type is #{type}"
          end

        Presenters::Shared::MediaResource::MediaResources.new(
          user_scope,
          @user,
          can_filter: true,
          list_conf: @list_conf,
          content_type: content_type,
          sub_filters: @sub_filters
        )
      end

      private

      def content_type
        case @resources_type
        when 'entries' then MediaEntry
        when 'collections' then Collection
        end
      end

      def entries_scope(meta_key_ids)
        scope = MediaEntry.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids }).distinct
        auth_policy_scope(@user, scope)
      end

      def collections_scope(meta_key_ids)
        scope = Collection.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids }).distinct
        auth_policy_scope(@user, scope)
      end

    end
  end
end
