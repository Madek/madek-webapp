# start the frontend bundler, but ONLY IF RUN AS DEV SERVER (no rake, console, …!)
if Rails.env == 'development' and defined?(Rails::Server)
  # build the translation files right before starting up in dev:
  `bin/translation-csv-to-locale-yamls`

  # run js bundler in background and watch mode (will be killed with ruby app)
  puts '=> Starting JS bundler/watcher'
  #spawn('npm run -s build:dev-app-embedded-view') # build dev bundle of embedded player once
  spawn('npm run -s watch-all')

  # enable the following when working on the embedded player (you might want to disable
  # the spawns listed above in order to avoid conflicts and double builds)
  # spawn('npm run -s watch:app-embedded-view')

  # watch SSR bundle for changes and reload it into the renderer pool
  ssr_bundle = Rails.root.join('public/assets/bundles/dev-bundle-react-server-side.js').to_s

  # custom asset container that reads directly from disk (bypasses Sprockets cache)
  React::ServerRendering::SprocketsRenderer.asset_container_class = Class.new do
    def find_asset(logical_path)
      File.read(Rails.root.join('public/assets/bundles', logical_path))
    end
  end

  Thread.new do
    last_mtime = File.exist?(ssr_bundle) ? File.mtime(ssr_bundle) : nil
    loop do
      sleep 2
      next unless File.exist?(ssr_bundle)
      current_mtime = File.mtime(ssr_bundle)
      if current_mtime != last_mtime
        last_mtime = current_mtime
        React::ServerRendering.reset_pool
        puts "=> SSR renderer pool reset (bundle changed)"
      end
    rescue => e
      puts "=> SSR watcher error: #{e.message}"
    end
  end
end
