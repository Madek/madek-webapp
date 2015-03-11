module Presenters
  module People
    class PersonCommon < Presenters::Shared::AppResource
      def name
        @resource.to_s
      end
    end
  end
end
