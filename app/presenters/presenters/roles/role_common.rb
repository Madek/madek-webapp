module Presenters
  module Roles
    class RoleCommon < Presenters::Shared::AppResource
      def label
        @app_resource.label(I18n.locale) \
          or @app_resource.label
      end

      def name
        label
      end
    end
  end
end
