module Presenters
  module Vocabularies
    class VocabularyShow < Presenters::Vocabularies::VocabularyIndex

      def meta_keys(vocabulary = @app_resource)
        vocabulary.meta_keys.map do |mk|
          Presenters::MetaKeys::VocabularyMetaKeyIndex.new(mk)
        end
      end

      def actions
        {
          index: prepend_url_context(vocabularies_path)
        }
      end

    end
  end
end
