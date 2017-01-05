module Presenters
  module Vocabularies
    class VocabularyContents < Presenter

      def initialize(vocabulary, user, list_conf)
        @vocabulary = vocabulary
        @user = user
        @list_conf = list_conf
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@vocabulary, user: @user)
      end

      def resources
        meta_key_ids = @vocabulary.meta_keys.map &:id
        scope = MediaEntry.joins(:meta_data).where(
          meta_data: { meta_key_id: meta_key_ids }).distinct
        user_scope = MediaEntryPolicy::Scope.new(@user, scope).resolve
        Presenters::Shared::MediaResource::MediaResources.new(
          user_scope, @user, list_conf: @list_conf
        )
      end
    end
  end
end
