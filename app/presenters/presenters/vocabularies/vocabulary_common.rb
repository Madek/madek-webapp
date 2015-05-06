module Presenters
  module Vocabularies
    class VocabularyCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:id,
                               :label,
                               :description,
                               :enabled_for_public_view,
                               :enabled_for_public_use)
    end
  end
end
