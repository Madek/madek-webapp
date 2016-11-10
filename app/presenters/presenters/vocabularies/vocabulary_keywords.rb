module Presenters
  module Vocabularies
    class VocabularyKeywords < Presenter

      def initialize(vocabulary, user: nil)
        @vocabulary = vocabulary
        @user = user
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@vocabulary, user: @user)
      end

      def meta_keys_with_keywords
        meta_key_resources.map do |meta_key|
          {
            meta_key: Presenters::MetaKeys::MetaKeyCommon.new(meta_key),
            keywords: meta_key_keywords(meta_key)
          }
        end
      end

      private

      def meta_key_keywords(meta_key)
        meta_key.keywords.map do |keyword|
          Presenters::Keywords::KeywordCommon.new(keyword)
        end
      end

      def meta_key_resources
        @vocabulary.meta_keys.where(
          meta_datum_object_type: 'MetaDatum::Keywords')
      end
    end
  end
end
