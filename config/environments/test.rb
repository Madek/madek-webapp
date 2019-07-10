IS_CI = ENV['CIDER_CI_TRIAL_ID'].present?
USE_STATIC_ASSETS = (
  # Defaults to true!
  # For testing, use precompiled assets;
  # it's faster and there is a dedicated test in CI to verify static assets.
  # We *do* have an option to just-in-time-precompile on "wip" branches
  # – locally we can check the branch, in CI we check an ENV var
  if IS_CI
    !ENV['MADEK_WIP_BRANCH'].present?
  else
    !`git rev-parse --abbrev-ref HEAD`.match(/^[a-z]*_wip_.*$/)
  end)

unless USE_STATIC_ASSETS
  if IS_CI
    puts '=> using assets precompiled in CI'
  else
    puts '=> bundling JS'
    `npm run build`
  end
end

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Use a different cache store in test
  config.cache_store = :memory_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = true

  if USE_STATIC_ASSETS || IS_CI # precompiled in CI is same as 'static'!
    config.assets.compile = false
  else
    config.assets.compile = true
  end

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
