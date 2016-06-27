module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResource::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource,
                     user,
                     user_scopes,
                     list_conf: nil)
        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @collection_selection = nil
      end

      def relations
        Presenters::Collections::CollectionRelations.new(
          @app_resource,
          @user,
          @user_scopes,
          list_conf: @list_conf)
      end

      def highlighted_media_resources
        Presenters::Collections::ChildMediaResources.new \
          @user_scopes[:highlighted_media_entries],
          @user,
          list_conf: @list_conf
      end

      def meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def permissions
        Presenters::Collections::CollectionPermissionsShow.new(
          @app_resource, @user)
      end

      def buttons
        buttons = [
          edit_button,
          favor_button,
          cover_button,
          destroy_button,
          select_collection_button,
          highlight_button
        ]
        buttons.select do |tab|
          tab[:allowed] == true
        end
      end

      def edit_button
        {
          async_action: nil,
          method: 'get',
          icon: 'pen',
          title: I18n.t(:resource_action_edit, raise: false),
          action: edit_context_meta_data_collection_path(@app_resource),
          allowed: policy(@user).meta_data_update?
        }
      end

      def favor_button
        {
          async_action: nil,
          method: 'patch',
          icon: favored ? 'favorite' : 'nofavorite',
          title: I18n.t(
            "resource_action_#{favored ? 'disfavor' : 'favor'}", raise: false),
          action: self.send(
            "#{favored ? 'disfavor' : 'favor'}_collection_path", @app_resource),
          allowed: favored ? policy(@user).disfavor? : policy(@user).favor?
        }
      end

      def cover_button
        {
          async_action: nil,
          method: 'get',
          icon: 'cover',
          title: I18n.t(:resource_action_edit_cover, raise: false),
          action: cover_edit_collection_path(@app_resource),
          allowed: policy(@user).update_cover?
        }
      end

      def destroy_button
        {
          async_action: nil,
          method: 'get',
          icon: 'trash',
          title: I18n.t(:resource_action_destroy, raise: false),
          action: ask_delete_collection_path(@app_resource),
          allowed: policy(@user).destroy?
        }
      end

      def select_collection_button
        {
          async_action: 'select_collection',
          method: 'get',
          icon: 'move',
          title: I18n.t(:resource_action_select_collection, raise: false),
          action: select_collection_collection_path(@app_resource),
          allowed: policy(@user).add_remove_collection?
        }
      end

      def highlight_button
        {
          async_action: nil,
          method: 'get',
          icon: 'highlight',
          title: I18n.t(:resource_action_edit_highlights, raise: false),
          action: highlights_edit_collection_path(@app_resource),
          allowed: policy(@user).update_highlights?
        }
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
