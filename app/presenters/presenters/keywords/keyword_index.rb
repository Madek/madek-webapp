module Presenters
  module Keywords
    class KeywordIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :term

      def url
        # TODO: vocabulary_meta_key_term_path
        term = @app_resource
        meta_key = term.meta_key.id.split(':').last
        vocabulary = term.meta_key.vocabulary.id
        "/ns/#{vocabulary}/#{meta_key}/#{term.id}"
      end
    end
  end
end
