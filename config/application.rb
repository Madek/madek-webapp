# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module MAdeK
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    #
    Dir["lib/**/*.rb"].each do |path|
        require_dependency path
    end

    config.autoload_paths += [
      Rails.root.join("lib"),
      Rails.root.join("app","models","concerns")
    ]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    # FIXME not working yet!!! config.active_record.identity_map = true

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Bern'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.version = '0.7.1'

    # Please add any files you need precompiled here, otherwise it breaks production
    config.assets.precompile += %w( application.js
                                    application.css
                                    pdf.js
                                    pdf-viewer.js
                                    pdf-viewer.css
                                    video.js
                                    video.css
                                    visualization_layout_web_worker.js
                                    visualization.js
                                    visualization.css
                                    test.js
                                  )

    # So that the Content-Length header is sent, so that e.g. video files
    # can be seeked and that mobile clients know how much data is coming
    config.middleware.use Rack::ContentLength

  end
end

YAML::ENGINE.yamler= 'syck' # TODO use psych ??

# Config files here.
METADATA_CONFIG_DIR = "#{Rails.root}/config/definitions/metadata"

# We have a variety of different storage location constants defined here because we *might* at some point want to optimise
# our storage (e.g. placing temp files on a fast filesystem, and permanent files in a 'slower' filesystem).
ZIP_STORAGE_DIR         = "#{Rails.root}/tmp/zipfiles" # NB This should be regularly cleaned
DOWNLOAD_STORAGE_DIR    = "#{Rails.root}/tmp/downloads" # this all needs rationalising, which will happen soon.

# NB This is sharded. Likely to be used infrequently.
FILE_STORAGE_DIR    = "#{Rails.root}/db/media_files/#{Rails.env}/attachments"
# NB This is sharded. A good candidate for a fast filesystem, since thumbnails will be used regularly.
THUMBNAIL_STORAGE_DIR = "#{Rails.root}/db/media_files/#{Rails.env}/attachments"

# symbolic links, to ultimately break your installation :-/
# $ sudo ln -s /usr/bin/exiftool /usr/local/bin/exiftool
# $ sudo ln -s /usr/bin/lib /usr/local/bin/lib
EXIFTOOL_CONFIG = "#{METADATA_CONFIG_DIR}/ExifTool_config.pl"
EXIFTOOL_PATH = "exiftool -config #{EXIFTOOL_CONFIG}"
# Ideally, this would work under script/server AND passenger, but it doesn't.
# Under passenger, it has no idea. Maybe substitute as part of the Capistrano deploy?
# EXIFTOOL_PATH = `/usr/bin/which exiftool`.gsub(/\n/,"")

FILE_UTIL_PATH = "/usr/bin/file -b --mime-type"

THUMBNAILS = {:maximum => nil, :x_large => '1024x768>', :large => '620x500>', :medium => '300x300>', :small_125 => '125x125>', :small => '100x100>'}
PER_PAGE = [36,100]

LANGUAGES = [:de_ch, :en_gb]
DEFAULT_LANGUAGE = :de_ch

ENCODING_BASE_URL = "http://test:MAdeK@test.madek.zhdk.ch"
ENCODING_TEST_MODE = 1 # 1 for true, 0 for false

RELEASE_VERSION = "0.8.0.1"
