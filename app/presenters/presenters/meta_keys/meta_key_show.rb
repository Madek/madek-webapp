module Presenters
  module MetaKeys
    class MetaKeyShow < Presenters::Shared::AppResource

      def vocabulary
        Presenters::Vocabularies::VocabularyCommon.new(@app_resource.vocabulary)
      end

    end
  end
end
