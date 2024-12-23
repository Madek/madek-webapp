require_relative 'boot'
require_relative('../datalayer/lib/madek/middleware/audit.rb')
$:.push File.expand_path('../../datalayer/lib', __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Madek
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    config.active_record.belongs_to_required_by_default = false
    config.active_record.yaml_column_permitted_classes = [Time, Date, Rational]
    config.assets.unknown_asset_fallback = true

    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller
    config.responders.flash_keys = [ :success, :error ]

    config.action_controller.relative_url_root = (
      ENV['RAILS_RELATIVE_URL_ROOT'].presence or '')
    config.action_controller.raise_on_missing_callback_actions = false

    config.active_record.timestamped_migrations = false
    # config.active_record.record_timestamps = false

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    config.paths['db/migrate'] << \
      Rails.root.join('datalayer', 'db', 'migrate')

    config.paths["config/initializers"] <<  \
      Rails.root.join('datalayer', 'initializers')

    config.eager_load_paths += [
      Rails.root.join('lib'),
      Rails.root.join('datalayer', 'lib'),
      Rails.root.join('datalayer', 'app', 'models', 'concerns'),
      Rails.root.join('datalayer', 'app', 'controllers'),
      Rails.root.join('datalayer', 'app', 'controllers', 'concerns'),
      Rails.root.join('datalayer', 'app', 'models'),
      Rails.root.join('datalayer', 'app', 'lib'),
      Rails.root.join('datalayer', 'app', 'queries'),
    ]

    # this should be in environments/test ; but that doesn't work (???)
    if Rails.env.test?
      config.eager_load_paths += [
        Rails.root.join('spec', 'lib')
      ]
    end

    # handle all error pages inside the app:
    config.action_dispatch.show_exceptions = true
    config.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }
    # to develop/debug error pages, set this to false in dev env as well:
    config.consider_all_requests_local = false

    # load translations from assets (they are precompiled for Rails from CSV table)
    config.i18n.load_path += Dir[
      Rails.root.join('public/assets/_rails_locales', '*.yml').to_s]

    require 'settings'
    config.i18n.default_locale = Settings.madek_default_locale
    config.i18n.enforce_available_locales = true

    # translations are part of the assets (JS), so watch them for changes:
    config.watchable_files
      .concat(Dir["#{Rails.root}/config/locale/*"])

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = ENV['RAILS_TIME_ZONE'].presence || 'UTC'

    if ENV['RAILS_LOG_LEVEL'].present?
      config.log_level = ENV['RAILS_LOG_LEVEL']
    else
      config.log_level = :info
    end

    # always log to stdout
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)

    config.log_tags = [->(req) { Time.now.strftime('%T') }, :port, :remote_ip]

    # Assets & React

    # NOTE: sprockets is not used for bundling JS, hand it the prebundled files:
    Rails.application.config.assets.paths.concat(
      Dir["#{Rails.root}/public/assets/bundles"])

    # react-rails config:
    # Settings for the pool of renderers:
    # config.react.server_renderer_pool_size  ||= 1  # ExecJS doesn't allow more than one on MRI
    # config.react.server_renderer_timeout    ||= 20 # seconds
    # config.react.server_renderer = React::ServerRendering::SprocketsRenderer
    pre_render_js_env = 'bundle-react-server-side.js' # no "dev" version because its never reloaded!
    config.react.server_renderer_options = {
      files: [pre_render_js_env].flatten, # files to load for prerendering
      replay_console: false, # if true, console.* will be replayed client-side
    }
    config.after_initialize do
      # inject (per-instance) app config into react renderer:
      class React::ServerRendering::SprocketsRenderer
        def before_render(_component_name, _props, _prerender_options)
          FrontendAppConfig.to_js
        end
      end
    end

    # List of all assets that need precompilation

    # the JS bundles are different for dev/prod:
    Rails.application.config.assets.precompile << %w(
      bundle.js
      bundle-embedded-view.js
    ).map { |name| "#{Rails.env.development? ? 'dev-' : ''}#{name}" }
    .concat(%w( bundle-react-server-side.js bundle-integration-testbed.js ))

    Rails.application.config.assets.precompile << %w(
      application.css
      application-contrasted.css
      embedded-view.css
      styleguide.css
    )

    # NOTE: Rails does not support *matchers* anymore, do it manually
    precompile_assets_dirs = %w(
      fonts/
      images/
      images/styleguide/
    )
    Rails.application.config.assets.precompile << Proc.new do |filename, path|
      precompile_assets_dirs.any? {|dir| path =~ Regexp.new("app/assets/#{dir}") }
    end

    # handle & precompile asset imports from npm
    Rails.application.config.assets.paths.concat(Dir[
      "#{Rails.root}/node_modules/@eins78/typopro-open-sans/dist",
      "#{Rails.root}/node_modules/font-awesome/fonts",
      "#{Rails.root}/node_modules"])

    # precompile assets from npm (only needed for fonts)
    Rails.application.config.assets.precompile.concat(Dir[
      "#{Rails.root}/node_modules/@eins78/typopro-open-sans/dist/*",
      "#{Rails.root}/node_modules/font-awesome/fonts/*"])

    # handle config/locale/*.csv
    Rails.application.config.assets.paths.concat(Dir["#{Rails.root}/config/locale"])
    config.assets.precompile.concat(Dir["#{Rails.root}/config/locale/*.csv"])

    Rails.application.config.middleware.insert_after Rack::TempfileReaper, Madek::Middleware::Audit
  end
end

# has to be done here, otherwise one gets 'unitialized constant' errors
# when hot loading code changes
require 'madek/constants'
