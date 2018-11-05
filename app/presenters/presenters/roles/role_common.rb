module Presenters
  module Roles
    # class RoleCommon < Presenters::People::PersonCommon
    class RoleCommon < Presenters::Shared::AppResource

      def term
        @app_resource.term(I18n.locale) \
          or @app_resource.term
      end

      def label
        term
      end

      def name
        label
      end

      def url(role = @app_resource)
        # prepend_url_context(vocabulary_meta_key_term_show_path(keyword.id))
        '/roles/' + label.parameterize
      end
    end
  end
end
