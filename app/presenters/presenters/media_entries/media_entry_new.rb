module Presenters
  module MediaEntries
    class MediaEntryNew < Presenter
      attr_reader :workflow

      def initialize(workflow = nil)
        super()
        @workflow = workflow
      end

      def next_step
        if workflow
          {
            label: I18n.t(:media_entry_media_import_gotoworkflow),
            url: prepend_url_context(workflow.actions.dig(:edit, :url))
          }
        else
          {
            label: I18n.t(:media_entry_media_import_gotodrafts),
            url: prepend_url_context(my_dashboard_section_path(:unpublished_entries))
          }
        end
      end

      # TODO: into_collection (upload into this collection, id comes from param)
    end
  end
end
