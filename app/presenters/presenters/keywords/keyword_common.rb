module Presenters
  module Keywords
    class KeywordCommon < Presenters::Shared::AppResource

      def label(term = @app_resource)
        term.term
      end

      def url(keyword = @app_resource)
        prepend_url_context(vocabulary_meta_key_term_show_path(keyword.id))
      end
    end
  end
end
