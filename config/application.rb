# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)
$:.push File.expand_path('../../datalayer/lib', __FILE__)

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

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
      Rails.root.join('app', 'lib'),
      Rails.root.join('app', 'policies'),
      Rails.root.join('app', 'views'),
      Rails.root.join('lib')
    ]

    config.paths["db/migrate"] << \
      Rails.root.join('datalayer', 'db', 'migrate')

    config.paths["config/initializers"] <<  \
      Rails.root.join('datalayer', 'initializers')

    config.autoload_paths += [
      Rails.root.join('datalayer', 'lib'),
      Rails.root.join('datalayer', 'app', 'models'),
      Rails.root.join('datalayer', 'app', 'lib'),
      Rails.root.join('datalayer', 'app', 'queries'),
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

    # load translations from assets (they are precompiled for Rails from CSV table)
    config.i18n.load_path += Dir[
      Rails.root.join('public/assets/_rails_locales', '*.yml').to_s]
    # TODO: select locale selection
    config.i18n.default_locale = :de
    # config.i18n.available_locales = [:de, :en]
    # config.i18n.enforce_available_locales = true

    # translations are part of the assets (JS), so watch them for changes:
    config.watchable_files
      .concat(Dir["#{Rails.root}/config/locale/*"])

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = ENV['RAILS_TIME_ZONE'].presence || 'UTC'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    if ENV['RAILS_LOG_LEVEL'].present?
      config.log_level = ENV['RAILS_LOG_LEVEL']
    else
      config.log_level = :info
    end

    config.log_tags = [->(req) { Time.now.strftime('%T') }, :port, :remote_ip]

    # Assets & React

    # Enable the asset pipeline
    config.assets.enabled = true

    # NOTE: sprockets is not used for bundling JS, hand it the prebundled files:
    Rails.application.config.assets.paths.concat(
      Dir["#{Rails.root}/public/assets/bundles"])

    # react-rails config:
    # Settings for the pool of renderers:
    # config.react.server_renderer_pool_size  ||= 1  # ExecJS doesn't allow more than one on MRI
    # config.react.server_renderer_timeout    ||= 20 # seconds
    # config.react.server_renderer = React::ServerRendering::SprocketsRenderer
    pre_render_js_env = if Rails.env == 'development'
      'dev-bundle-react-server-side.js'
    else
      'bundle-react-server-side.js'
    end
    config.react.server_renderer_options = {
      files: [pre_render_js_env], # files to load for prerendering
      replay_console: false,      # if true, console.* will be replayed client-side
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
    # NOTE: override (don't extend) the Rails default (which matches lots of garbage)!
    config.assets.precompile = %w(
      bundle.js
      bundle-react-server-side.js
      bundle-integration-testbed.js
      application.css
      application-contrasted.css
    )

    # NOTE: Rails does not support *matchers* anymore, do it manually
    precompile_assets_dirs = %w(
      fonts/
      images/
    )
    config.assets.precompile << Proc.new do |filename, path|
      precompile_assets_dirs.any? {|dir| path =~ Regexp.new("app/assets/#{dir}") }
    end

    # .handle config/locale/*.csv
    Rails.application.config.assets.paths.concat(Dir["#{Rails.root}/config/locale"])
    config.assets.precompile.concat(Dir["#{Rails.root}/config/locale/*.csv"])
  end
end

# has to be done here, otherwise one gets 'unitialized constant' errors
# when hot loading code changes
require 'madek/constants'
