module Presenters
  module Helpers
    module Helpers
      private

      def _media_entry_title(media_entry)
        media_entry.title \
          or media_entry.try(:media_file).try(:filename) \
          or "(Upload from #{media_entry.created_at.iso8601})"
      end

      def _collection_title(collection)
        collection.title.presence or '<Collection has no title>'
      end

      def _resource_title(resource)
        resource.title
      end

    end
  end
end
