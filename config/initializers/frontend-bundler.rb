# start the frontend bundler, but ONLY IF RUN AS DEV SERVER (no rake, console, …!)
if Rails.env == 'development' and defined?(Rails::Server)
  # reinstall node_modules only if they differ from package-lock.json
  if `npm install --dry-run --ignore-scripts --no-audit --no-fund 2>/dev/null`.include?('up to date')
    puts '=> node_modules in sync with package-lock.json, skipping `npm ci`'
  else
    puts '=> node_modules out of sync, running `npm ci --ignore-scripts`...'
    system('npm ci --ignore-scripts', exception: true)
  end

  # build the translation files right before starting up in dev:
  `bin/translation-csv-to-locale-yamls.mjs`

  # run js bundler in background and watch mode (will be killed with ruby app)
  puts '=> Starting JS bundler/watcher'
  spawn('npm run -s watch-all')
end
