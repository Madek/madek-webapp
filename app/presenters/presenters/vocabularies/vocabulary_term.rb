module Presenters
  module Vocabularies
    class VocabularyTerm < Presenter

      def initialize(vocabulary, keyword, contents_path)
        @vocabulary = vocabulary
        @keyword = keyword
        @contents_path = contents_path
      end

      attr_accessor :contents_path

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def meta_key
        Presenters::MetaKeys::MetaKeyCommon.new(@keyword.meta_key)
      end

      def keyword
        Presenters::Keywords::KeywordShow.new(@keyword)
      end

    end
  end
end
