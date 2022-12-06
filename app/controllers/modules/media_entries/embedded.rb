module Modules
  module MediaEntries
    module Embedded
      extend ActiveSupport::Concern

      # NOTE: we distinguish between "fullscreen" and "embed". Some cosmetic differences,
      # but the main one: "embed" is only allowed for public or confidential entries,
      # e.g. it wont show something that is dependent on the logged in users' permissions!

      include EmbedHelper
      EMBED_SUPPORTED_MEDIA = Madek::Constants::Webapp::EMBED_SUPPORTED_MEDIA
      FULLSCREEN_SUPPORTED_MEDIA = Madek::Constants::Webapp::FULLSCREEN_SUPPORTED_MEDIA
      EMBED_INTERNAL_HOST_WHITELIST = Madek::Constants::Webapp::\
        EMBED_INTERNAL_HOST_WHITELIST

      included do
        layout false, only: [:embedded, :fullscreen]

        # NOTE: we execute this ourselfes so we can catch the error…
        skip_before_action :check_and_redirect_with_custom_url,
                           unless: :action_handled_by_confidential_links?
        before_action do
          # allow this to be displayed inside an <iframe>
          response.headers.delete('X-Frame-Options')
          _with_failsafe { check_and_redirect_with_custom_url }
        end
      end

      def fullscreen
        media_entry = MediaEntry.unscoped.find(id_param)
        media_type = media_entry.try(:media_file).try(:media_type)
        handle_confidential_links(media_entry)
        set_response_options(media_entry)

        # NOTE: just the default webapp error handling (this is the main difference to "embedded")
        auth_authorize(media_entry, :fullscreen?)

        # errors
        unless FULLSCREEN_SUPPORTED_MEDIA.include?(media_type)
          raise ActionController::BadRequest, "media type '#{media_type}' not supported!"
        end
        unless media_entry.try(:media_file).try(:previews).try(:any?)
          raise ActiveRecord::RecordNotFound, 'no previews found!'
        end

        conf = params.permit(:width, :height, :ratio)

        @get = Presenters::MediaEntries::MediaEntryEmbedded.new(media_entry, conf)
          .dump.merge(authToken: nil)

        render(:fullscreen)
      end

      def embedded
        media_entry = _with_failsafe { MediaEntry.unscoped.find(id_param) }
        media_type = media_entry.try(:media_file).try(:media_type)
        handle_confidential_links(media_entry) if media_entry
        return embedded_error_message(404) unless media_entry.present?
        set_response_options(media_entry)

        # only whitelisted hosts can hide the title etc
        # by default this is for our OWN ui!
        is_internal = embed_whitelisted? && params.keys.include?('internalEmbed')

        # - special case policy: differ for internal and external embeds.
        # - special case error handling: dont raise `UnauthorizedError`,
        #   because we want to show a custom error message
        begin
          if is_internal
            auth_authorize(media_entry, :embedded_internally?)
          else
            auth_authorize(media_entry, :embedded_externally?)
          end
        rescue Pundit::NotAuthorizedError
          return embedded_error_message(403)
        end

        # errors
        unless EMBED_SUPPORTED_MEDIA.include?(media_type)
          return embedded_error_message(501)
        end

        unless media_entry.try(:media_file).try(:previews).try(:any?)
          return embedded_error_message(400)
        end

        conf = params.permit(:width, :height, :ratio)
          .merge(isInternal: is_internal, referer_info: referer_info)

        @get = Presenters::MediaEntries::MediaEntryEmbedded.new(media_entry, conf)
          .dump.merge(authToken: nil)

        has_player = ['audio', 'video'].include?(@get[:media_type])
        render(has_player ? 'embedded' : 'embedded_image')
      rescue StandardError
        return embedded_error_message # ensure all errors are handled with custom view
      end

      private

      def set_response_options(media_entry)
        # dont cache the page if accessed via ConfidentialLink!
        disable_http_caching if media_entry.accessed_by_confidential_link
      end

      def embedded_error_message(status_code = 500)
        skip_authorization # not needed anymore, just showing an error message
        disable_http_caching # never cache the error page!
        render(
          'errors/embedded_error',
          status: status_code,
          locals: { status_code: status_code, wanted_url: wanted_url })
      end

      def wanted_url
        begin
          u = URI.parse(request.path)
          u.path.sub!(%r{/(embedded|fullscreen)$}, '')
          absolute_full_url(u)
        rescue
          request.url
        end
      end

    end
  end
end
