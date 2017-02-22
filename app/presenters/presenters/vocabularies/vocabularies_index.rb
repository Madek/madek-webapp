module Presenters
  module Vocabularies
    class VocabulariesIndex < Presenter

      def initialize(resources, user)
        @resources = resources
        @user = user
      end

      # simple list, no pagination etc
      def resources
        @resources
          .map do |v|
            {
              vocabulary: \
                Presenters::Vocabularies::VocabularyIndex.new(v, user: @user),
              meta_keys: v.meta_keys.map do |mk|
                Presenters::MetaKeys::MetaKeyCommon.new(mk)
              end
            }
          end
      end

      def title
        I18n.t(:sitemap_vocabularies)
      end
    end
  end
end
