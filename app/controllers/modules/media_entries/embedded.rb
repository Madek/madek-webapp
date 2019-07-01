module Modules
  module MediaEntries
    module Embedded
      extend ActiveSupport::Concern

      include EmbedHelper
      EMBED_SUPPORTED_MEDIA = Madek::Constants::Webapp::EMBED_SUPPORTED_MEDIA
      EMBED_INTERNAL_HOST_WHITELIST = Madek::Constants::Webapp::\
        EMBED_INTERNAL_HOST_WHITELIST

      included do
        layout false, only: [:embedded]
      end

      def embedded
        # allow this to be displayed inside an <iframe>
        response.headers.delete('X-Frame-Options')

        media_entry = MediaEntry.unscoped.find(id_param)
        media_type = media_entry.try(:media_file).try(:media_type)
        handle_confidential_links(media_entry)

        # only whitelisted hosts can hide the title etc
        # by default this is for our OWN ui!
        is_internal = embed_whitelisted? && params.keys.include?('internalEmbed')

        # - special case policy: differ for internal and external embeds.
        # - special case error handling: dont raise `UnauthorizedError`,
        # because logging in won't change the result (see policy for why)
        begin
          if is_internal
            auth_authorize(media_entry, :embedded_internally?)
          else
            auth_authorize(media_entry, :embedded_externally?)
          end
        rescue Pundit::NotAuthorizedError
          raise Errors::ForbiddenError
        end

        # errors
        unless EMBED_SUPPORTED_MEDIA.include?(media_type)
          raise ActionController::NotImplemented, "media: #{EMBED_SUPPORTED_MEDIA}"
        end

        unless media_entry.try(:media_file).try(:previews).try(:any?)
          raise ActiveRecord::RecordNotFound, 'no media!'
        end

        conf = params.permit(:width, :height, :ratio)
          .merge(isInternal: is_internal, referer_info: referer_info)

        @get = Presenters::MediaEntries::MediaEntryEmbedded.new(media_entry, conf)
          .dump.merge(authToken: nil)

        has_player = ['audio', 'video'].include?(@get[:media_type])
        render(has_player ? 'embedded' : 'embedded_tiled')
      end

    end
  end
end
