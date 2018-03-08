module Presenters
  module MediaEntries
    class MediaEntryConfidentialLinkIndex < \
      Presenters::Shared::MediaResource::MediaResourceConfidentialLinkIndex

      def actions
        {
          revoke: policy_for(@user).update? && {
            url: prepend_url_context(
              update_confidential_link_media_entry_path(
                @app_resource.resource,
                confidential_link_id: @app_resource.id
              )
            ),
            method: 'PATCH'
          },
          show: {
            url: prepend_url_context(
              confidential_link_media_entry_path(
                @app_resource.resource,
                @app_resource)
            )
          }
        }
      end

    end
  end
end
