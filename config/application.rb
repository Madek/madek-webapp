# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module MAdeK
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_record.timestamped_migrations = false

    config.active_record.disable_implicit_join_references = true

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    config.autoload_paths += [
      Rails.root.join('app', 'api'),
      Rails.root.join('app', 'lib'),
      Rails.root.join('app', 'models', 'concerns'),
      Rails.root.join('app', 'modules'),
      Rails.root.join('app', 'views'),
      Rails.root.join('lib')
    ]

    # this should be in environments/test ; but that doesn't work (???)
    if Rails.env.test?
      config.autoload_paths += [
        Rails.root.join('spec', 'lib')
      ]
    end

    config.i18n.enforce_available_locales = false
    config.i18n.available_locales = ['de', 'de-CH', 'en', 'en-GB']
    config.i18n.default_locale = 'de-CH'

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Bern'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # get rid of annoying warning; have a look at this again when dealing with i18n
    config.i18n.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.log_level = ENV['RAILS_LOG_LEVEL'] if ENV['RAILS_LOG_LEVEL'].present?
    # config.log_level = :debug

    config.log_tags = [->(req) { Time.now.strftime('%T') }, :port, :remote_ip]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.version = '1.0.0'

    config.assets.initialize_on_precompile = false

    # Please add any files you need precompiled here, otherwise it breaks production
    config.assets.precompile += %w(
      *.png
      api_docs.css
      api_docs.js
      admin.css
      admin.js
      application.css
      application-contrasted.css
      application.js
      i18n/locale/*
      plupload/*
      pdf-viewer.css
      pdf.js
      styleguide.css
      test.js
      upload.js
      video.css
      video.js
      visualization.css
      visualization.js
      visualization_layout_web_worker.js
    )

  end
end

# some constants externalized so they can be accessed from outside of rails

# Directory config
load Rails.root.join('config/directories_config.rb')
DOWNLOAD_STORAGE_DIR  = DirectoriesConfig::DOWNLOAD_STORAGE_DIR
FILE_STORAGE_DIR      = DirectoriesConfig::FILE_STORAGE_DIR
THUMBNAIL_STORAGE_DIR = DirectoriesConfig::THUMBNAIL_STORAGE_DIR
ZIP_STORAGE_DIR       = DirectoriesConfig::ZIP_STORAGE_DIR

FILE_UTIL_PATH = '/usr/bin/file -b --mime-type'

# UI constants
UI_GENERIC_THUMBNAIL = {
  # relative to `app/assets/images`
  collection: 'thumbnails/set.png',
  filter_set: 'dev_todo.png',
  incomplete: 'dev_todo.png',
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
# # Under passenger, it has no idea. Maybe substitute as part of the Capistrano deploy?
# # EXIFTOOL_PATH = `/usr/bin/which exiftool`.gsub(/\n/,"")
#
# THUMBNAILS = { maximum: nil, x_large: '1024x768', large: '620x500', medium: '300x300', small_125: '125x125', small:  '100x100' }
# PER_PAGE = [36, 100]
#
# LANGUAGES = [:de_ch, :en_gb]
# DEFAULT_LANGUAGE = :de_ch
