module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def initialize(
        app_resource,
        user,
        user_scopes,
        list_conf: nil,
        show_collection_selection: false,
        search_term: '')

        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @show_collection_selection = show_collection_selection
        @search_term = search_term
      end

      def tabs # list of all 'show' action sub-tabs
        tabs_config.select do |tab|
          tab[:action] ? policy(@user).send("#{tab[:action]}?".to_sym) : true
        end.reject do |tab|
          tab[:id] == 'relations' \
            && relations.parent_collections.empty? \
            && relations.sibling_collections.empty?
        end
      end

      def relations
        Presenters::Shared::MediaResource::MediaResourceRelations.new \
          @app_resource, @user, @user_scopes, list_conf: @list_conf
      end

      def resource_index
        Presenters::MediaEntries::MediaEntryIndex.new(@app_resource, @user)
      end

      # TODO: move meta_data to MediaResourceShow
      def meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def more_data
        Presenters::MediaEntries::MediaEntryMoreData.new(@app_resource)
      end

      def permissions
        Presenters::MediaEntries::MediaEntryPermissions.new(@app_resource, @user)
      end

      def header
        Presenters::MediaEntries::MediaEntryHeader.new(
          @app_resource,
          @user,
          show_collection_selection: @show_collection_selection,
          search_term: @search_term)
      end

      def copyright_notice
        @app_resource
          .meta_data
          .find_by(meta_key_id: 'madek_core:copyright_notice')
          .try(:value)
      end

      def portrayed_object_date
        @app_resource
          .meta_data
          .find_by(meta_key_id: 'madek_core:portrayed_object_date')
          .try(:value)
      end

      def image_url
        size = :large
        img = @media_file.previews.try(:fetch, :images, nil).try(:fetch, size, nil)
        img.url if img.present?
      end

      private

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
