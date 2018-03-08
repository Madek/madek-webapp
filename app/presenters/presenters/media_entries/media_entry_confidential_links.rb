module Presenters
  module MediaEntries
    class MediaEntryConfidentialLinks < Presenters::Shared::AppResourceWithUser

      def list
        @app_resource.confidential_links.map do |tu|
          Presenters::MediaEntries::MediaEntryConfidentialLinkIndex.new(tu, @user)
        end
      end

      def resource
        Presenters::MediaEntries::MediaEntryIndex.new(@app_resource, @user)
      end

      def actions
        {
          new: {
            url: prepend_url_context(
              new_confidential_link_media_entry_path(@app_resource))
          },
          go_back: {
            url: prepend_url_context(
              media_entry_path(@app_resource)
            )
          }
        }
      end

    end
  end
end
