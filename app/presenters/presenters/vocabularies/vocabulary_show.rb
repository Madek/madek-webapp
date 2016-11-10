module Presenters
  module Vocabularies
    class VocabularyShow < Presenter

      def initialize(app_resource, user:)
        @app_resource = app_resource
        @user = user
      end

      def meta_keys(vocabulary = @app_resource)
        vocabulary.meta_keys.map do |mk|
          Presenters::MetaKeys::VocabularyMetaKeyIndex.new(mk)
        end
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@app_resource)
      end
    end
  end
end
