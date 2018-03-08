module Presenters
  module MediaEntries
    class MediaEntryConfidentialLinkShow < \
      Presenters::Shared::MediaResource::MediaResourceConfidentialLinkCommon

      def initialize(resource, user, base_url)
        super(resource, user)
        @base_url = URI.parse(base_url)
      end

      def secret_url
        full_url(
          show_by_confidential_link_media_entry_path(@app_resource.resource,
                                                     @app_resource.token)
        )
      end

      def actions
        {
          index: {
            url: prepend_url_context(
              confidential_links_media_entry_path(@app_resource.resource))
          }
        }
      end

      private

      def full_url(path)
        @base_url.merge(prepend_url_context(path)).to_s
      end

    end
  end
end
