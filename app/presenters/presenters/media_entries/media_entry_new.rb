module Presenters
  module MediaEntries
    class MediaEntryNew < Presenter

      def next_url
        prepend_url_context my_dashboard_section_path(:unpublished_entries)
      end

      # TODO: into_collection (upload into this collection, id comes from param)

    end
  end
end
