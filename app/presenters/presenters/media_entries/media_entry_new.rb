module Presenters
  module MediaEntries
    class MediaEntryNew < Presenter

      def next_url
        # FIXME: `my_dashboard_path(:unpublished_entries)` gives wrong result :(
        prepend_url_context '/my/unpublished_entries'
      end

      # TODO: into_collection (upload into this collection, id comes from param)

    end
  end
end
