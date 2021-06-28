module Presenters
  module MediaEntries
    class MediaEntryConfidentialLinkShow < \
      Presenters::ConfidentialLinks::ConfidentialLinkCommon

      DEFAULT_WIDTH = 640
      DEFAULT_HEIGHT = 360

      def initialize(resource, user, base_url)
        super(resource, user)
        @base_url = URI.parse(base_url)
      end

      def secret_url
        # NOTE: MUST use UUID-based url, because a custom URL can be moved to
        #       another resource without moving the accessToken
        full_url(
          show_by_confidential_link_media_entry_path(
            @app_resource.resource.id, @app_resource.token)
        )
      end

      def embed_link
        @_embed_link ||= \
        full_url(
          embedded_media_entry_path(
            @app_resource.resource,
            accessToken: @app_resource.token,
            height: DEFAULT_HEIGHT,
            width: DEFAULT_WIDTH))
      end

      def embed_html_code
        oembed_iframe(embed_link)
      end

      def actions
        {
          index: {
            url: prepend_url_context(
              confidential_links_media_entry_path(@app_resource.resource))
          },
          go_back: {
            url: prepend_url_context(
              media_entry_path(@app_resource.resource.id)
            )
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
          <div class="___madek-embed ___madek-confidential-link"><iframe
          src="#{ERB::Util.html_escape(url)}"
          frameborder="0"
          width="#{DEFAULT_WIDTH}"
          height="#{DEFAULT_HEIGHT}"
          style="margin:0;padding:0;border:0"
          allowfullscreen webkitallowfullscreen mozallowfullscreen
          ></iframe></div>
        HTML
      end

    end
  end
end
