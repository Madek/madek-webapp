module Presenters
  module Shared
    module MediaResource
      class ShareResource < Presenters::Shared::AppResource

        def initialize(app_resource, user, base_url)
          super(app_resource)
          @user = user
          @base_url = base_url
        end

        def title
          @app_resource.title
        end

        def resource_url
          prepend_url_context(
            send("#{underscore}_path", @app_resource)
          )
        end

        def uuid_url
          @base_url + prepend_url_context(
            send("#{underscore}_path", @app_resource.id)
          )
        end

        def primary_custom_url
          primary_urls = @app_resource.custom_urls.select &:is_primary

          return if primary_urls.empty?

          @base_url + prepend_url_context(
            send("#{underscore}_path", primary_urls[0].id)
          )
        end

        def embed_html_code
          return unless @app_resource.is_a?(MediaEntry)
          w = Madek::Constants::Webapp::EMBED_UI_DEFAULT_WIDTH
          h = (w / Madek::Constants::Webapp::EMBED_UI_DEFAULT_RATIO).to_i
          url = @base_url + prepend_url_context(
            embedded_media_entry_path(@app_resource, width: w, height: h)
          )
          # NOTE: based on app/controllers/oembed_controller.rb
          <<-HTML.strip_heredoc.tr("\n", ' ').strip
            <div class="___madek-embed"><iframe
            src="#{ERB::Util.html_escape(url)}"
            frameborder="0"
            width="#{w}"
            height="#{h}"
            style="margin:0;padding:0;border:0"
            allowfullscreen webkitallowfullscreen mozallowfullscreen
            ></iframe></div>
          HTML
        end

        private

        def underscore
          @app_resource.class.name.underscore
        end
      end
    end
  end
end
