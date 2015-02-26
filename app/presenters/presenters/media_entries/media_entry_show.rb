module Presenters
  module MediaEntries
    class MediaEntryShow < Presenters::Shared::Resources::ResourceShow
      include Presenters::MediaEntries::MediaEntryHelpers

      attr_reader :more_data

      def initialize(resource, user)
        super(resource, user)
        @relations = \
          Presenters::MediaEntries::Relations.new(@resource, @user)
        @more_data = Presenters::MediaEntries::MoreData.new(@resource)
      end

      def copyright_notice
        @resource
          .meta_data
          .find_by(meta_key_id: 'madek:core:copyright_notice')
          .try(:value)
      end

      def portrayed_object_date
        @resource
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
