module Madek
  module Constants
    module Webapp
      FILE_UTIL_PATH = '/usr/bin/file -b --mime-type'

      # UI constants
      UI_GENERIC_THUMBNAIL = {
        # relative to `app/assets/images`
        collection: 'thumbnails/set.png',
        filter_set: 'thumbnails/dev_todo.png',
        incomplete: 'thumbnails/dev_todo.png',
        unknown: 'thumbnails/document_unknown.png'
      }

      # embed
      EMBED_SUPPORTED_RESOURCES = ['media_entries'].freeze
      EMBED_MEDIA_TYPES_MAP = {
        # madek_type : oembed_type
        video: :video,
        audio: :rich,
        image: :rich
      }.freeze
      EMBED_SUPPORTED_MEDIA = EMBED_MEDIA_TYPES_MAP.keys.map(&:to_s).freeze
      # pixels:
      EMBED_UI_DEFAULT_WIDTH = 500
      EMBED_UI_DEFAULT_HEIGHT = 500
      EMBED_UI_DEFAULT_HEIGHTS = { audio: 200 }
      EMBED_UI_MIN_WIDTH = 320
      EMBED_UI_MIN_HEIGHT = 140
      EMBED_UI_EXTRA_HEIGHT = 55 # (added by tile on bottom)

      # oEmbed
      OEMBED_VERSION = '1.0'.freeze # should never change, spec is frozen
      OEMBED_API_ENDPOINT = '/oembed'.freeze
      # if a config (according to oEmbed spec) is needed, it would be like this:
      # OEMBED_CONFIG = [{ # pairs of supported URL schemes and their API endpoint
      #     url_scheme: 'https://madek.example.com/entries/*',
      #     api_endpoint: 'https://madek.example.com/oembed'
      # }]

      webapp_embeds = Settings.webapp_embeds || {}
      ENABLE_OPENGRAPH = webapp_embeds[:enable_opengraph]
      TWITTER_CARDS_SITE = webapp_embeds[:twitter_cards_site]

      VERIFY_AUTH_SKIP_CONTROLLERS = \
        [ConfigurationManagementBackdoorController,
         ErrorsController,
         MadekZhdkIntegration::AuthenticationController,
         StyleguideController,
         ZencoderJobsController]

      # From v2, unused but kept here for reference:
      # # Config files here.
      # METADATA_CONFIG_DIR = "#{Rails.root}/config/definitions/metadata"
      #
      # # symbolic links, to ultimately break your installation :-/
      # # $ sudo ln -s /usr/bin/exiftool /usr/local/bin/exiftool
      # # $ sudo ln -s /usr/bin/lib /usr/local/bin/lib
      # EXIFTOOL_CONFIG = "#{METADATA_CONFIG_DIR}/ExifTool_config.pl"
      # EXIFTOOL_PATH = "exiftool -config #{EXIFTOOL_CONFIG}"
      # # Ideally, this would work under script/server AND passenger,
      # # but it doesn't.
      # # Under passenger, it has no idea.
      # # Maybe substitute as part of the Capistrano deploy?
      # # EXIFTOOL_PATH = `/usr/bin/which exiftool`.gsub(/\n/,"")
      #
      # PER_PAGE = [36, 100]
      #
      # LANGUAGES = [:de_ch, :en_gb]
      # DEFAULT_LANGUAGE = :de_ch
    end
  end
end
