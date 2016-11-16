module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::AppResource

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::Shared::MediaResource::Modules::PrivacyStatus
      include Presenters::Shared::MediaResource::Modules::EditSessions

      def initialize(
        app_resource,
        user,
        user_scopes,
        action: 'show',
        list_conf: nil,
        show_collection_selection: false,
        search_term: '')

        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @show_collection_selection = show_collection_selection
        @search_term = search_term
        # NOTE: this is just a hack to help separating the methods by action/tab
        #       modal actions are all still on top of 'show'
        @active_tab = action
      end

      def tabs # list of all 'show' action sub-tabs
        tabs_config.select do |tab|
          tab[:action] ? policy(@user).send("#{tab[:action]}?".to_sym) : true
        end.reject do |tab|
          tab[:id] == 'relations' \
            && _relations.parent_collections.empty? \
            && _relations.sibling_collections.empty?
        end
      end

      def relations
        return unless @active_tab == 'relations'
        Presenters::Shared::MediaResource::MediaResourceRelations.new \
          @app_resource, @user, @user_scopes, list_conf: @list_conf
      end

      def meta_data
        return unless ['show', 'export', 'more_data'].include?(@active_tab)
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def more_data
        return unless @active_tab == 'more_data'
        Presenters::MediaEntries::MediaEntryMoreData.new(@app_resource)
      end

      def edit_sessions
        return unless @active_tab == 'more_data'
        super
      end

      def permissions
        return unless ['permissions', 'permissions_edit'].include?(@active_tab)
        Presenters::MediaEntries::MediaEntryPermissions.new(@app_resource, @user)
      end

      def header
        Presenters::MediaEntries::MediaEntryHeader.new(
          @app_resource,
          @user,
          show_collection_selection: @show_collection_selection,
          search_term: @search_term)
      end

      def image_url
        size = :large
        img = media_file.previews.try(:fetch, :images, nil).try(:fetch, size, nil)
        img.url if img.present?
      end

      private

      # NOTE: used by tab helper, because tab should not be shown if no relations
      def _relations
        @_relations ||= Presenters::Shared::MediaResource::MediaResourceRelations
          .new(@app_resource, @user, @user_scopes, list_conf: @list_conf)
      end

      def tabs_config
        [
          {
            id: 'main',
            action: nil,
            title: I18n.t(:media_entry_tab_main)
          },
          {
            id: 'relations',
            action: 'relations',
            title: I18n.t(:media_entry_tab_relations)
          },
          {
            id: 'more_data',
            action: 'more_data',
            title: I18n.t(:media_entry_tab_more_data)
          },
          {
            id: 'permissions',
            action: 'permissions',
            title: I18n.t(:media_entry_tab_permissions),
            icon_type: :privacy_status_icon
          }
        ]
      end
    end
  end
end
