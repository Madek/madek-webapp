module Presenters
  module Collections
    class CollectionHeader < Presenters::Shared::AppResource

      include Presenters::Shared::Modules::Favoritable
      include Presenters::Shared::Modules::SharedHeader

      def initialize(
        app_resource,
        user,
        search_term: ''
      )

        super(app_resource)
        @user = user
        @search_term = search_term
      end

      delegate_to_app_resource :title

      def url
        collection_path(@app_resource)
      end

      def buttons
        buttons = [
          edit_button,
          favor_button,
          cover_button,
          destroy_button,
          select_collection_button,
          highlight_button,
          share_button,
          custom_urls_button
        ]
        buttons.select do |tab|
          tab[:allowed] == true
        end
      end

      def dropdown_actions
        [
          :cover_button,
          :highlight_button,
          :custom_urls_button,
          :destroy_button
        ]
      end

      private

      def edit_button
        shared_edit_button(Collection, @app_resource, @user)
      end

      def favor_button
        shared_favor_button(Collection, @app_resource, @user)
      end

      def cover_button
        {
          id: :cover_button,
          async_action: nil,
          method: 'get',
          icon: 'cover',
          title: I18n.t(
            :resource_action_collection_edit_cover,
            raise: false),
          action: cover_edit_collection_path(@app_resource),
          allowed: policy_for(@user).update_cover?
        }
      end

      def destroy_button
        shared_destroy_button(Collection, @app_resource, @user)
        {
          id: :destroy_button,
          async_action: nil,
          method: 'get',
          icon: 'trash',
          title: I18n.t(
            :resource_action_collection_destroy,
            raise: false),
          action: ask_delete_collection_path(@app_resource),
          allowed: policy_for(@user).destroy?
        }
      end

      def select_collection_button
        {
          id: :select_collection_button,
          async_action: 'select_collection',
          method: 'get',
          icon: 'move',
          title: I18n.t(
            :resource_action_collection_select_collection,
            raise: false),
          action: select_collection_collection_path(@app_resource),
          allowed: policy_for(@user).select_collection?
        }
      end

      def highlight_button
        {
          id: :highlight_button,
          async_action: nil,
          method: 'get',
          icon: 'highlight',
          title: I18n.t(
            :resource_action_collection_edit_highlight,
            raise: false),
          action: highlights_edit_collection_path(@app_resource),
          allowed: policy_for(@user).update_highlights?
        }
      end

      def custom_urls_button
        {
          id: :custom_urls_button,
          async_action: nil,
          method: 'get',
          icon: 'vis-graph',
          title: I18n.t(
            :resource_action_collection_edit_custom_urls,
            raise: false),
          action: custom_urls_collection_path(@app_resource),
          allowed: policy_for(@user).update_custom_urls?
        }
      end

      def share_button
        {
          id: :share_button,
          async_action: 'share',
          method: 'get',
          fa: 'fa fa-share',
          title: I18n.t(
            :resource_action_collection_share,
            raise: false),
          action: share_collection_path(@app_resource),
          allowed: policy_for(@user).share?
        }
      end
    end
  end
end
