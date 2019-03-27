module Presenters
  module Contexts
    class ContextCommon < Presenters::Shared::AppResource

      def label
        @app_resource.label(I18n.locale) \
          or @app_resource.label
      end

      def description
        @app_resource.description(I18n.locale) \
          or @app_resource.description
      end

    end
  end
end
