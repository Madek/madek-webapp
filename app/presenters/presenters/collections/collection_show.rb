module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResource::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource,
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
        [
          {
            active: false,
            action: nil,
            icon_type: nil,
            label: I18n.t(:collection_tab_main),
            href: collection_path(@app_resource) },
          {
            active: false,
            action: 'relations',
            icon_type: nil,
            label: I18n.t(:media_entry_tab_relations),
            href: relations_collection_path(@app_resource) },
          {
            active: false,
            action: 'more_data',
            icon_type: nil,
            label: I18n.t(:media_entry_tab_more_data),
            href: more_data_collection_path(@app_resource) },
          {
            active: false,
            action: 'permissions',
            icon_type: :privacy_status_icon,
            label: I18n.t(:media_entry_tab_permissions),
            href: permissions_collection_path(@app_resource) }
        ].select do |tab|
          tab[:action] ? policy(@user).send("#{tab[:action]}?") : true
        end
      end

    end
  end
end
