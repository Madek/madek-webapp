module Presenters
  module Roles
    # class RoleCommon < Presenters::People::PersonCommon
    class RoleCommon < Presenters::Shared::AppResource

      def label(role = @app_resource)
        role.term
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
