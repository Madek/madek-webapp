module Presenters
  module Vocabularies
    class VocabularyPermissions < Presenter

      def initialize(vocabulary, user)
        @vocabulary = vocabulary
        @user = user
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@vocabulary)
      end

      def page
        Presenters::Vocabularies::VocabularyPage.new(@vocabulary, user: @user)
      end

      def permissions
        Presenters::Vocabularies::VocabularyPermissionsShow.new(@vocabulary, @user)
      end

    end
  end
end
