module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::MediaEntries::Modules::MediaEntryPreviews

      def initialize(app_resource, user, user_scopes,
        list_conf: nil)
        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
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
        img = preview_helper(type: :image, size: :large)
        img.present? ? img.url : generic_thumbnail_url
      end

      def audio_previews
        preview_helper(type: :audio, size: :large)
      end

      def video_previews
        preview_helper(type: :video, size: :large)
      end

    end
  end
end
