module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def initialize(app_resource, user, user_scopes, list_conf: nil)
        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @collection_selection = nil
      end

      def tabs # list of all 'show' action sub-tabs
        {
          nil => { title: I18n.t(:media_entry_tab_main) },
          relations: { title: I18n.t(:media_entry_tab_relations) },
          more_data: { title: I18n.t(:media_entry_tab_more_data) },
          permissions: {
            title: I18n.t(:media_entry_tab_permissions),
            icon_type: :privacy_status_icon }
        }.select do |action, tab|
          action ? policy(@user).send("#{action}?".to_sym) : true
        end
      end

      def relations
        Presenters::Shared::MediaResource::MediaResourceRelations.new \
          @app_resource, @user, @user_scopes, list_conf: @list_conf
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

      def buttons
        buttons = [
          edit_button,
          destroy_button,
          favor_button,
          select_collection_button,
          export_button
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
          action: edit_context_meta_data_media_entry_path(@app_resource),
          allowed: policy(@user).meta_data_update?
        }
      end

      def destroy_button
        {
          async_action: nil,
          method: 'get',
          icon: 'trash',
          title: I18n.t(:resource_action_destroy, raise: false),
          action: ask_delete_media_entry_path(@app_resource),
          allowed: policy(@user).destroy?
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
            "#{favored ? 'disfavor' : 'favor'}_media_entry_path", @app_resource),
          allowed: favored ? policy(@user).disfavor? : policy(@user).favor?
        }
      end

      def select_collection_button
        {
          async_action: 'select_collection',
          method: 'get',
          icon: 'move',
          title: I18n.t(:resource_action_select_collection, raise: false),
          action: select_collection_media_entry_path(@app_resource),
          allowed: policy(@user).add_remove_collection?
        }
      end

      def export_button
        {
          async_action: nil,
          method: 'get',
          icon: 'dload',
          title: I18n.t(:resource_action_export, raise: false),
          action: export_media_entry_path(@app_resource),
          allowed: policy(@user).export?
        }
      end
    end
  end
end
