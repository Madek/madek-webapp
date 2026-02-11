# Be sure to restart your server when you modify this file.

if Rails.env.development?
  puts "run `npm ci` to make sure `node_modules` are up to date..."
  system('npm ci')
end

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

Rails.application.config.assets.gzip = false

# NOTE: sprockets is not used for bundling JS, hand it the prebundled files:
Rails.application.config.assets.paths.concat(
  Dir["#{Rails.root}/public/assets/bundles"])

  # the JS bundles are different for dev/prod:
Rails.application.config.assets.precompile << %w(
  bundle.js
  bundle-embedded-view.js
).map { |name| "#{Rails.env.development? ? 'dev-' : ''}#{name}" }
.concat(%w( bundle-react-server-side.js bundle-integration-testbed.js ))

# CSS
Rails.application.config.assets.precompile << %w(
  application.css
  application-contrasted.css
  embedded-view.css
  styleguide.css
)

# NOTE: Rails does not support *matchers* anymore, do it manually
precompile_assets_dirs = %w(
  fonts/
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
Rails.application.config.assets.precompile.concat(Dir["#{Rails.root}/config/locale/*.csv"])
