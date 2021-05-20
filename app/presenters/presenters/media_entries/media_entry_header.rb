# rubocop:disable Metrics/ClassLength
module Presenters
  module MediaEntries
    class MediaEntryHeader < Presenters::Shared::AppResource

      include Presenters::Shared::Modules::Favoritable
      include Presenters::Shared::Modules::SharedHeader
      include Presenters::Shared::Modules::ShowableInAdmin
      include Presenters::Shared::Modules::PartOfWorkflow

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
          confidential_link_button,
          browse_button,
          update_file_button,
          show_in_admin_button
        ]
        buttons.select do |tab|
          tab[:allowed] == true
        end
      end

      def dropdown_actions
        [
          :browse_button,
          :update_file_button,
          :custom_urls_button,
          :confidential_link_button,
          :export_button,
          :destroy_button,
          :show_in_admin_button
        ]
      end

      def new_version_entries
        ::MetaDatum::MediaEntry
          .where(other_media_entry_id: @app_resource.id)
          .joins('INNER JOIN media_entries ON meta_data.other_media_entry_id = media_entries.id')
          .reorder('media_entries.created_at DESC')
          .select do |md|
            # only show if other entry is visible and both entries have same responsible
            @app_resource.responsible_user_id == md.media_entry.responsible_user_id \
            && auth_policy(@user, md.media_entry).show?
          end
          .map do |md|
            p = Presenters::MediaEntries::MediaEntryIndex.new(md.media_entry, @user)
            {
              entry: { title: p.title, url: p.url, date: p.created_at_pretty },
              description: md.string
            }
          end
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

      def confidential_link_button
        {
          id: :confidential_link_button,
          async_action: nil,
          method: 'get',
          icon: 'clock-o',
          title: I18n.t(
            :resource_action_media_entry_manage_confidential_links,
            raise: false),
          action: confidential_links_media_entry_path(@app_resource),
          allowed: policy_for(@user).confidential_links?
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

      def update_file_button
        {
          id: :update_file_button,
          async_action: nil,
          method: 'get',
          icon: 'upload',
          title: I18n.t(:resource_action_media_entry_update_file),
          action: new_media_entry_path('copy-md-from-id': @app_resource.id),
          allowed: policy_for(@user).update_file?
        }
      end
    end
  end
end
