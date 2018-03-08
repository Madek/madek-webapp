module Presenters
  module MediaEntries
    class MediaEntryConfidentialLinkNew < Presenters::Shared::AppResourceWithUser

      def actions
        {
          create: {
            url: prepend_url_context(
              create_confidential_link_media_entry_path(@app_resource)),
            method: 'POST'
          }
        }
      end
    end
  end
end
