module Presenters
  module KeywordTerms
    class KeywordTermIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :term
    end
  end
end
