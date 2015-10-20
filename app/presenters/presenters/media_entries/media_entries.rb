module Presenters
  module MediaEntries
    class MediaEntries < Presenters::MediaResources::MediaResources

      private

      def indexify(media_entries)
        indexify_with_presenter(media_entries,
                                Presenters::MediaEntries::MediaEntryIndex)
      end
    end
  end
end
