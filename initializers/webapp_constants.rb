require 'madek/constants'

module Madek
  module Constants
    FILE_UTIL_PATH = '/usr/bin/file -b --mime-type'

    # TMP: Displayed Vocabularies, "most important" MetaKeys. TODO: put in DB
    UI_META_CONFIG = {
      summary_vocabulary: :madek_core,    # WIP: the built-in core vocabulary
      title_meta_key: 'madek_core:title',
      displayed_vocabularies: [
        :media_content, # "Werk" - meaning the WorkOfArt encoded in MediaFile
        :media_object,  # "Medium" - meaning the MediaFile as a WorkOfArt
        :copyright,     # to be cleaned up…
        :zhdk_bereich,
        :doesnt_exist
      ]
    }

    # UI constants
    UI_GENERIC_THUMBNAIL = {
      # relative to `app/assets/images`
      collection: 'thumbnails/set.png',
      filter_set: 'thumbnails/dev_todo.png',
      incomplete: 'thumbnails/dev_todo.png',
      unknown: 'thumbnails/document_unknown.png'
    }

    # From v2, unused but kept here for reference:
    # # Config files here.
    # METADATA_CONFIG_DIR = "#{Rails.root}/config/definitions/metadata"
    #
    # # symbolic links, to ultimately break your installation :-/
    # # $ sudo ln -s /usr/bin/exiftool /usr/local/bin/exiftool
    # # $ sudo ln -s /usr/bin/lib /usr/local/bin/lib
    # EXIFTOOL_CONFIG = "#{METADATA_CONFIG_DIR}/ExifTool_config.pl"
    # EXIFTOOL_PATH = "exiftool -config #{EXIFTOOL_CONFIG}"
    # # Ideally, this would work under script/server AND passenger, but it doesn't.
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
