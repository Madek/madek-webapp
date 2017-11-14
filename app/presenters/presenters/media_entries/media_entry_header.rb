module Presenters
  module MediaEntries
    class MediaEntryHeader < Presenters::Shared::AppResource

      include Presenters::Shared::Modules::Favoritable
      include Presenters::Shared::Modules::SharedHeader
      include Presenters::Shared::Modules::ShowableInAdmin

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
        media_entry_path(@app_resource)
      end

      def select_collection_url
        select_collection_media_entry_path(@app_resource)
      end

      def share_url
        share_media_entry_path(@app_resource)
      end

      def buttons
        buttons = [
          edit_button,
          destroy_button,
          favor_button,
          select_collection_button,
          share_button,
          export_button,
          custom_urls_button,
          browse_button,
          show_in_admin_button
        ]
        buttons.select do |tab|
          tab[:allowed] == true
        end
      end

      def dropdown_actions
        [
          :browse_button,
          :custom_urls_button,
          :export_button,
          :destroy_button,
          :show_in_admin_button
        ]
      end

      private

      def edit_button
        shared_edit_button(MediaEntry, @app_resource, @user)
      end

      def destroy_button
        shared_destroy_button(MediaEntry, @app_resource, @user)
      end

      def favor_button
        shared_favor_button(MediaEntry, @app_resource, @user)
      end

      def select_collection_button
        {
          id: :select_collection_button,
          async_action: 'select_collection',
          method: 'get',
          icon: 'move',
          title: I18n.t(
            :resource_action_media_entry_select_collection,
            raise: false),
          action: select_collection_media_entry_path(@app_resource),
          allowed: policy_for(@user).select_collection?
        }
      end

      def export_button
        {
          id: :export_button,
          async_action: nil,
          method: 'get',
          icon: 'dload',
          title: I18n.t(
            :resource_action_media_entry_export,
            raise: false),
          action: export_media_entry_path(@app_resource),
          allowed: policy_for(@user).export?
        }
      end

      def custom_urls_button
        {
          id: :custom_urls_button,
          async_action: nil,
          method: 'get',
          icon: 'vis-graph',
          title: I18n.t(
            :resource_action_media_entry_edit_custom_urls,
            raise: false),
          action: custom_urls_media_entry_path(@app_resource),
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
            :resource_action_media_entry_share,
            raise: false),
          action: share_media_entry_path(@app_resource),
          allowed: policy_for(@user).share?
        }
      end

      def browse_button
        {
          id: :browse_button,
          async_action: nil,
          method: 'get',
          icon: 'eye',
          title: I18n.t(
            :browse_entries_title,
            raise: false),
          action: browse_media_entry_path(@app_resource),
          allowed: policy_for(@user).browse?
        }
      end
    end
  end
end
