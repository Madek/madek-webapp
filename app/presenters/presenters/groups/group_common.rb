module Presenters
  module Groups
    class GroupCommon < Presenters::Shared::AppResource
      delegate_to_app_resource :name,
                               :institutional?,
                               :institutional_group_name
    end
  end
end
