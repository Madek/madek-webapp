module Presenters
  module Roles
    class RoleCommon < Presenters::Shared::AppResource

      def label(role = @app_resource)
        role.term
      end

      def name
        "#{@app_resource.meta_key.label}: #{label}"
      end

      def url(role = @app_resource)
        # prepend_url_context(vocabulary_meta_key_term_show_path(keyword.id))
        '/foo'
      end
    end
  end
end
