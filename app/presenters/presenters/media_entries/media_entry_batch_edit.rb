module Presenters
  module MediaEntries
    class MediaEntryBatchEdit < Presenter

      def initialize(resource_type, media_entries, user, return_to:)
        @resource_type = resource_type
        @entries = media_entries
        @user = user
        @return_to = return_to
      end

      attr_reader :return_to

      def resource_type
        @resource_type.name.underscore
      end

      def resources
        Presenters::Shared::MediaResource::IndexResources.new(@user, @entries)
      end

      def batch_entries
        @entries.map do |entry|
          Presenters::Shared::MediaResource::MediaResourceEdit.new(entry, @user)
        end
      end

      def submit_url
        self.send('batch_meta_data_' +
          @resource_type.name.pluralize.underscore + '_path')
      end

    end
  end
end
