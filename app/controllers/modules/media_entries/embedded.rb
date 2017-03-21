module Modules
  module MediaEntries
    module Embedded
      extend ActiveSupport::Concern

      EMBED_SUPPORTED_MEDIA = Madek::Constants::Webapp::EMBED_SUPPORTED_MEDIA

      included do
        layout false, only: [:embedded]
      end

      def embedded
        # custom auth, only public entries supported!
        skip_authorization
        media_entry = MediaEntry.find(id_param)
        media_type = media_entry.try(:media_file).try(:media_type)
        # errors
        raise Errors::ForbiddenError unless media_entry.get_metadata_and_previews
        unless EMBED_SUPPORTED_MEDIA.include?(media_type)
          raise ActionController::NotImplemented, "media: #{EMBED_SUPPORTED_MEDIA}"
        end
        unless media_entry.try(:media_file).try(:previews).try(:any?)
          raise ActionController::NotFound, 'no media!'
        end

        conf = params.permit(:width, :height)

        # allow this to be displaye inside an <iframe>
        response.headers.delete('X-Frame-Options')

        @get = Presenters::MediaEntries::MediaEntryEmbedded.new(media_entry, conf)
      end

    end
  end
end
