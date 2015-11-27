module Presenters
  module People
    class PersonCommon < Presenters::Shared::AppResource
      def name
        @app_resource.to_s
      end

      def label
        name
      end

    end
  end
end
