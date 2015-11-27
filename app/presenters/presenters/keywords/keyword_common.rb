module Presenters
  module Keywords
    class KeywordCommon < Presenters::Shared::AppResource

      def label(term = @app_resource)
        term.term
      end

      def url(term = @app_resource)
        # TODO: vocabulary_meta_key_term_path
        meta_key = term.meta_key.id.split(':').last
        vocabulary = term.meta_key.vocabulary.id
        prepend_url_context_fucking_rails \
          "/ns/#{vocabulary}/#{meta_key}/#{term.id}"
      end
    end
  end
end
