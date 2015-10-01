# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)
$:.push File.expand_path('../../engines/datalayer/lib', __FILE__)

# Dependencies:
begin
  require 'rails/all'
  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(:default, Rails.env)

  # Check npm (javascript) dependencies (behaves like `bundler`)
  raise unless system('./bin/check_npm_deps')
rescue => e
  puts 'missing dependencies! Invoke ./dev/bundle to install them!'
  exit(1)
end

module Madek
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller
    config.responders.flash_keys = [ :success, :error ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #

    config.action_controller.relative_url_root = \
      ENV['RAILS_RELATIVE_URL_ROOT'].presence or ''

    config.active_record.timestamped_migrations = false
    config.active_record.record_timestamps = false
    config.active_record.raise_in_transactional_callbacks = true
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

    config.paths["db/migrate"] << \
      Rails.root.join('engines', 'datalayer', 'db', 'migrate')

    config.paths["config/initializers"] <<  \
      Rails.root.join('engines', 'datalayer', 'initializers')

    config.autoload_paths += [
      Rails.root.join('engines', 'datalayer', 'lib'),
      Rails.root.join('engines', 'datalayer', 'app', 'models'),
      Rails.root.join('engines', 'datalayer', 'app', 'lib'),
    ]

    # this should be in environments/test ; but that doesn't work (???)
    if Rails.env.test?
      config.autoload_paths += [
        Rails.root.join('spec', 'lib')
      ]
    end

    # handle all error pages inside the app:
    config.show_execptions = true
    config.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }
    # to develop/debug error pages, set this to false in dev env as well:
    config.consider_all_requests_local = false

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
    config.i18n.load_path += Dir[Rails.root.join('locale', '*.yml').to_s]
    # TODO: select locale at runtime and set to `:en` here:
    config.i18n.default_locale = :de

    # get rid of annoying warning; have a look at this again when dealing with i18n
    # config.i18n.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.log_level = :info
    config.log_level = ENV['RAILS_LOG_LEVEL'] if ENV['RAILS_LOG_LEVEL'].present?

    config.log_tags = [->(req) { Time.now.strftime('%T') }, :port, :remote_ip]

    # Assets

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.version = '1.0.0'

    config.assets.initialize_on_precompile = false

    # Paths, that should be browserified. We browserify everything, that
    # matches (===) one of the paths. So you will most likely put lambdas
    # regexes in here.
    #
    # By default only files in /app and /node_modules are browserified,
    # vendor stuff is normally not made for browserification and may stop
    # working.
    # config.browserify_rails.paths << %r{vendor/assets/javascripts/module.js}

    # we `require` locale yaml files with browserify, so explicitly watch them:
    config.watchable_files.concat(Dir["#{Rails.root}/locale/**/*.yml"])

    # Environments, in which to generate source maps
    # The default is none
    config.browserify_rails.source_map_environments << 'development'

    # Command line options used when running browserify
    # NOTE: all browserify config itself is in `package.json`
    # config.browserify_rails.commandline_options = []

    # Should the node_modules directory be evaluated for changes on page load
    #
    # The default is `false`
    config.browserify_rails.evaluate_node_modules = true

    # react-rails config:
    # Settings for the pool of renderers:
    # config.react.server_renderer_pool_size  ||= 1  # ExecJS doesn't allow more than one on MRI
    # config.react.server_renderer_timeout    ||= 20 # seconds
    # config.react.server_renderer = React::ServerRendering::SprocketsRenderer
    config.react.server_renderer_options = {
      files: ['react-server-side.js'], # files to load for prerendering
      replay_console: false,                # if true, console.* will be replayed client-side
    }
    # since we use non-standard `.cjsx` files, we need to explicitly watch them
    config.watchable_files.concat(Dir["#{Rails.root}/app/assets/javascripts/**/*.cjsx*"])
    config.react.variant = :production

    # Please add any files you need precompiled here, otherwise it breaks production.
    # JS Note: only application.js and admin.js are needed here as entry points
    #          react-server-side.js must also be bundled (but not included in web)
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
      pdf-viewer.css
      react-server-side.js
      styleguide.css
      video.css
      visualization.css
    )
  end
end

# some constants externalized so they can be accessed from outside of rails

# Semver: get semantic version as a parsed Hash.
MADEK_SEMVER = YAML.safe_load(File.read('.release.yml'))['semver']\
                .merge(build: ["g#{`git log -n1 --format='%h'`}".gsub(/\n/, '')])

require 'madek/constants'

# TODO remove resp. namespace all these global things

FILE_UTIL_PATH = '/usr/bin/file -b --mime-type'

# TMP: Displayed Vocabularies, "most important" MetaKeys. TODO: put in DB
UI_META_CONFIG = {
  displayed_vocabularies: [
    :media_content, # "Werk" - meaning the WorkOfArt encoded in MediaFile
    :media_object,  # "Medium" - meaning the MediaFile as a WorkOfArt
    :copyright,     # to be cleaned up…
    :zhdk_bereich
  ],
  summary_meta_keys: [
    'media_content:title',
    'media_content:description',
    'media_content:author',
    'media_content:keywords'
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
# # Under passenger, it has no idea. Maybe substitute as part of the Capistrano deploy?
# # EXIFTOOL_PATH = `/usr/bin/which exiftool`.gsub(/\n/,"")
#
THUMBNAILS = { maximum: nil,
               x_large: { width: 1024, height: 768 },
               large: { width: 620, height: 500 },
               medium: { width: 300, height: 300 },
               small_125: { width: 125, height: 125 },
               small: { width: 100, height: 100 } }
# PER_PAGE = [36, 100]
#
# LANGUAGES = [:de_ch, :en_gb]
# DEFAULT_LANGUAGE = :de_ch
