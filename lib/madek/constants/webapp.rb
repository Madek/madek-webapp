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
      EMBED_SUPPORTED_MEDIA = ['video'].freeze
      EMBED_UI_EXTRA_HEIGHT = 55 # pixels (added by tile on bottom)

      # oEmbed
      OEMBED_VERSION = '1.0'.freeze # should never change, spec is frozen
      OEMBED_API_ENDPOINT = '/oembed'.freeze
      # if a config (according to oEmbed spec) is needed, it would be like this:
      # OEMBED_CONFIG = [{ # pairs of supported URL schemes and their API endpoint
      #     url_scheme: 'https://madek.example.com/entries/*',
      #     api_endpoint: 'https://madek.example.com/oembed'
      # }]

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
