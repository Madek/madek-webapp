module Presenters
  module Groups
    class GroupCommon < Presenters::Shared::AppResource

      delegate_to_app_resource :name,
                               :institutional?,
                               :institutional_group_name

      def initialize(app_resource, user = nil, list_conf: nil)
        super(app_resource)
        @user = user
        @list_conf = list_conf
      end

      def url
        prepend_url_context_fucking_rails my_group_path(@app_resource)
      end

    end
  end
end
