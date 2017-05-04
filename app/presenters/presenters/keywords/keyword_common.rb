module Presenters
  module Keywords
    class KeywordCommon < Presenters::Shared::AppResource

      def label(term = @app_resource)
        term.term
      end

      def url(keyword = @app_resource)
        prepend_url_context(
          vocabulary_meta_key_term_path(
            term: keyword.term, meta_key_id: keyword.meta_key_id))
      end
    end
  end
end
