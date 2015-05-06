module Presenters
  module MetaKeys
    class MetaKeyCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:id,
                               :description,
                               :vocabulary_id,
                               :position)

      def label
        @app_resource.label or @app_resource.id
      end

      def type
        @app_resource.meta_datum_object_type
      end

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@app_resource.vocabulary)
      end
    end
  end
end
