module Presenters
  module Groups
    class GroupCommon < Presenters::Shared::AppResource
      delegate_to_app_resource :name,
                               :institutional?,
                               :institutional_group_name

      def url
       my_group_path(@app_resource)
      end

    end
  end
end
