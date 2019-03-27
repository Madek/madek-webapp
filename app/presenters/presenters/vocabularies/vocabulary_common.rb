module Presenters
  module Vocabularies
    class VocabularyCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:position,
                               :enabled_for_public_view,
                               :enabled_for_public_use)

      def label
        @app_resource.label(I18n.locale) \
          or @app_resource.label
      end

      def description
        @app_resource.description(I18n.locale) \
          or @app_resource.description
      end

      def url
        vocabulary_path(@app_resource)
      end
    end
  end
end
