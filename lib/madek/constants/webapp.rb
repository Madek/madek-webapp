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

      UI_CONTEXT_LIST = [
        # summary context/"Das Wichtigste":
        'core', # NOT 'madek_core' vocab!!!
        # 4 extra contexts:
        #    ZHdK     |       Werk     |    Personen   |   Rechte
        'zhdk_bereich', 'media_content', 'media_object', 'copyright'
      ]

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
