module Presenters
  module People
    class PersonCommon < Presenters::Shared::AppResource
      def name
        @app_resource.to_s
      end

      def label
        name
      end

      def url
        prepend_url_context_fucking_rails person_path(@app_resource)
      end

    end
  end
end
