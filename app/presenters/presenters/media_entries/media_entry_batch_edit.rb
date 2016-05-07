module Presenters
  module MediaEntries
    class MediaEntryBatchEdit < Presenter

      def initialize(media_entries, user)
        @entries = media_entries
        @user = user
      end

      def resources
        Presenters::Shared::MediaResource::IndexResources.new(@user, @entries)
      end

      def batch_entries
        @entries.map do |entry|
          Presenters::MediaEntries::MediaEntryEditMetaData.new(entry, @user)
        end
      end

      def submit_url
        batch_meta_data_media_entries_path
      end

    end
  end
end
