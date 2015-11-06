module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::MediaResource::MediaResourceShow

      include Presenters::MediaEntries::Modules::MediaEntryCommon
      include Presenters::MediaEntries::Modules::MediaEntryMetaData

      def relations
        Presenters::Shared::MediaResource::MediaResourceRelations.new \
          @app_resource, @user, list_conf: @list_conf
      end

      # TODO: move meta_data to MediaResourceShow ?
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
        image_url_helper(:large)
      end
    end
  end
end
