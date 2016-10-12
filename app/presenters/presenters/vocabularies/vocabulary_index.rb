module Presenters
  module Vocabularies
    class VocabularyIndex < Presenters::Vocabularies::VocabularyCommon

      def initialize(app_resource, user:)
        super(app_resource)
        @user = user
      end

      def usable
        @app_resource.usable_by_public? || @app_resource.usable_by_user?(@user)
      end

      def url
        prepend_url_context(vocabulary_path(@app_resource))
      end

    end
  end
end
