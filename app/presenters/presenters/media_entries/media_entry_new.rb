module Presenters
  module MediaEntries
    class MediaEntryNew < Presenter
      attr_reader :workflow

      def initialize(workflow = nil)
        super()
        @workflow = workflow
      end

      def next_url
        if workflow
          prepend_url_context workflow.actions.dig(:edit, :url)
        else
          prepend_url_context my_dashboard_section_path(:unpublished_entries)
        end
      end

      # TODO: into_collection (upload into this collection, id comes from param)

    end
  end
end
