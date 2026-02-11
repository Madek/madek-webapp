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
end
