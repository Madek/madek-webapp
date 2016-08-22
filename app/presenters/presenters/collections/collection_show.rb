module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResource::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource,
                     user,
                     user_scopes,
                     list_conf: nil,
                     active_tab: 'show',
                     show_collection_selection: false,
                     search_term: '')
        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @active_tab = active_tab
        @show_collection_selection = show_collection_selection
        @search_term = search_term
      end

      attr_reader :active_tab

      def relations
        @relations ||= Presenters::Collections::CollectionRelations.new(
          @app_resource,
          @user,
          @user_scopes,
          list_conf: @list_conf)
      end

      def highlighted_media_resources
        resources = @app_resource.child_media_resources.select do |resource|
          resource.highlighted_for?(@app_resource)
        end
        Presenters::Shared::MediaResource::IndexResources.new(
          @user,
          resources
        )
      end

      def resource_index
        Presenters::Collections::CollectionIndex.new(@app_resource, @user)
      end

      def meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def permissions
        Presenters::Collections::CollectionPermissionsShow.new(
          @app_resource, @user)
      end

      def header
        Presenters::Collections::CollectionHeader.new(
          @app_resource,
          @user,
          show_collection_selection: @show_collection_selection,
          search_term: @search_term)
      end

      def tabs
        tabs_config.select do |tab|
          tab[:action] ? policy(@user).send("#{tab[:action]}?") : true
        end.reject do |tab|
          tab[:id] == 'relations' \
            && relations.child_collections.empty? \
            && relations.parent_collections.empty? \
            && relations.sibling_collections.empty?
        end
      end

      private

      def tabs_config
        [
          {
            id: 'show',
            label: I18n.t(:collection_tab_main),
            href: collection_path(@app_resource) },
          {
            id: 'relations',
            label: I18n.t(:media_entry_tab_relations),
            href: relations_collection_path(@app_resource) },
          {
            id: 'more_data',
            label: I18n.t(:media_entry_tab_more_data),
            href: more_data_collection_path(@app_resource) },
          {
            id: 'permissions',
            icon_type: :privacy_status_icon,
            label: I18n.t(:media_entry_tab_permissions),
            href: permissions_collection_path(@app_resource) }
        ]
      end
    end
  end
end
