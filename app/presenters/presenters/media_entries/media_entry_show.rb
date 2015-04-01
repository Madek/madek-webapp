module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::MediaResources::MediaResourceShow

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      # TODO: move meta_data to MediaResourceShow ?
      attr_reader :more_data, :meta_data

      def initialize(app_resource, user)
        super(app_resource, user)
        @relations = \
          Presenters::MediaEntries::MediaEntryRelations.new(@app_resource, @user)
        @more_data = Presenters::MediaEntries::MoreData.new(@app_resource)
        @meta_data = \
          Presenters::MetaData::MetaDataPresenter.new(@app_resource, @user)
      end

      def copyright_notice
        @app_resource
          .meta_data
          .find_by(meta_key_id: 'madek:core:copyright_notice')
          .try(:value)
      end

      def portrayed_object_date
        @app_resource
          .meta_data
          .find_by(meta_key_id: 'madek:core:portrayed_object_date')
          .try(:value)
      end

      def image_url
        image_url_helper(:large)
      end
    end
  end
end
