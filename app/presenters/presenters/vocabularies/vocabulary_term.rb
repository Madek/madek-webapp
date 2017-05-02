module Presenters
  module Vocabularies
    class VocabularyTerm < Presenter

      def initialize(
        vocabulary,
        keyword,
        contents_path,
        user,
        resources_type,
        list_conf)

        @vocabulary = vocabulary
        @keyword = keyword
        @contents_path = contents_path
        @user = user
        @resources_type = resources_type
        @list_conf = list_conf
      end

      attr_accessor :contents_path

      def vocabulary
        Presenters::Vocabularies::VocabularyIndex.new(
          @vocabulary, user: @user)
      end

      def meta_key
        Presenters::MetaKeys::MetaKeyCommon.new(
          @keyword.meta_key)
      end

      def keyword
        Presenters::Keywords::KeywordShow.new(
          @user, @keyword, @resources_type, @list_conf)
      end

    end
  end
end
