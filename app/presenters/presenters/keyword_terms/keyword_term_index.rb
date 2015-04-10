module Presenters
  module KeywordTerms
    class KeywordTermIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :term

      def url
        # TODO: vocabulary_meta_key_term_path
        term = @app_resource
        meta_key = @app_resource.meta_key
        vocabulary = meta_key.vocabulary
        "/[NOTIMPLEMENTED]/#{vocabulary.id}/#{meta_key.id}/#{term.id}"
      end
    end
  end
end
