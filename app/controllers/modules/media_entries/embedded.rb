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
        media_entry = MediaEntry.unscoped.find(id_param)
        authorize(media_entry)
        media_type = media_entry.try(:media_file).try(:media_type)

        # non-public entries can only be embedded from whitelisted hosts
        unless embed_whitelisted? || media_entry.get_metadata_and_previews
          return redirect_to(media_entry_path(media_entry))
        end
        # only whitelisted hosts can hide the title etc
        is_internal = embed_whitelisted? && params.keys.include?('internalEmbed')

        # errors
        unless EMBED_SUPPORTED_MEDIA.include?(media_type)
          raise ActionController::NotImplemented, "media: #{EMBED_SUPPORTED_MEDIA}"
        end

        unless media_entry.try(:media_file).try(:previews).try(:any?)
          raise ActiveRecord::RecordNotFound, 'no media!'
        end

        conf = params.permit(:width, :height, :ratio)
          .merge(isInternal: is_internal)

        # allow this to be displayed inside an <iframe>
        response.headers.delete('X-Frame-Options')

        @get = Presenters::MediaEntries::MediaEntryEmbedded.new(media_entry, conf)
          .dump.merge(authToken: nil)

        has_player = ['audio', 'video'].include?(@get[:media_type])
        render(has_player ? 'embedded' : 'embedded_tiled')
      end

    end
  end
end
