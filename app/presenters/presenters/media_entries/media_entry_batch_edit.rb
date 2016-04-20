module Presenters
  module MediaEntries
    class MediaEntryBatchEdit < Presenter

      attr_reader :batch_entries

      def initialize(media_entries, current_user)
        @batch_entries = media_entries.map do |entry|
          Presenters::MediaEntries::MediaEntryEdit.new(entry, current_user)
        end
      end

      def submit_url
        batch_meta_data_media_entries_path
      end

    end
  end
end
