module Presenters
  module Groups
    class GroupCommon < Presenters::Shared::AppResource

      delegate_to_app_resource :name,
                               :institutional?,
                               :institutional_name

      def initialize(app_resource, user = nil, list_conf: nil)
        super(app_resource)
        @user = user # NOTE: is optional!
        @list_conf = list_conf
      end

      def label
        name
      end

      def detailed_name
        if institutional_name and not institutional_name.empty?
          "#{name} (#{institutional_name})"
        else
          name
        end
      end

      # def current_user_is_member
      #   can_edit ? true : @user && @app_resource.users.exists?(@user.id)
      # end

      def edit_url
        can_edit && the_edit_url
      end

      def can_show
        (auth_policy(@user, @app_resource).show? if @user)
      end

      def url
        prepend_url_context my_group_path(@app_resource)
      end

      private

      def can_edit
        @_can_edit ||= (auth_policy(@user, @app_resource).edit? if @user)
      end

      def the_edit_url
        prepend_url_context edit_my_group_path(@app_resource)
      end

    end
  end
end
