module Presenters
  module Vocabularies
    class VocabularyPage < Presenter

      def initialize(vocabulary, user: nil)
        @vocabulary = vocabulary
        @user = user
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyIndex.new(@vocabulary, user: @user)
      end

      def show_keywords
        keyword_keys = @vocabulary.meta_keys.select do |meta_key|
          meta_key.meta_datum_object_type == 'MetaDatum::Keywords'
        end
        not keyword_keys.empty?
      end

      def actions
        {
          index: prepend_url_context(vocabularies_path),
          vocabulary: prepend_url_context(vocabulary_path(@vocabulary)),
          vocabulary_keywords: prepend_url_context(
            vocabulary_keywords_path(@vocabulary)),
          vocabulary_contents: prepend_url_context(
            vocabulary_contents_path(@vocabulary)),
          vocabulary_permissions: prepend_url_context(
            vocabulary_permissions_path(@vocabulary))
        }
      end
    end
  end
end
