module Presenters
  module People
    class PersonCommon < Presenters::Shared::AppResource
      def name
        @app_resource.to_s
      end
    end
  end
end
