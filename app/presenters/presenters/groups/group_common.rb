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

      def label
        name
      end

      def detailed_name
        if institutional_group_name and not institutional_group_name.empty?
          "#{name} (#{institutional_group_name})"
        else
          name
        end
      end

      def url
        prepend_url_context my_group_path(@app_resource)
      end
    end
  end
end
