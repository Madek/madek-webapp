module Presenters
  module MediaEntries
    class MediaEntryConfidentialLinkShow < \
      Presenters::Shared::MediaResource::MediaResourceConfidentialLinkCommon

      DEFAULT_WIDTH = 640
      DEFAULT_HEIGHT = 360

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

      def embed_html_code
        oembed_iframe(full_url(
                        embedded_media_entry_path(
                          @app_resource.resource,
                          accessToken: @app_resource.token,
                          height: DEFAULT_HEIGHT,
                          width: DEFAULT_WIDTH)))
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

      # NOTE: based on app/controllers/oembed_controller.rb
      def oembed_iframe(url)
        <<-HTML.strip_heredoc.tr("\n", ' ').strip
          <div class="___madek-embed"><iframe
          src="#{url}"
          frameborder="0"
          width="#{DEFAULT_WIDTH}px"
          height="#{DEFAULT_HEIGHT}px"
          style="margin:0;padding:0;border:0"
          allowfullscreen webkitallowfullscreen mozallowfullscreen
          ></iframe></div>
        HTML
      end

    end
  end
end
