module Presenters
  module Groups
    class GroupIndex < GroupCommon
      def url
        group_path(@app_resource)
      end
    end
  end
end
