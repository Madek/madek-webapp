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

      def actions
        {
          index: prepend_url_context(vocabularies_path),
          vocabulary: prepend_url_context(vocabulary_path(@vocabulary)),
          vocabulary_keywords: prepend_url_context(
            vocabulary_keywords_path(@vocabulary))
        }
      end
    end
  end
end
