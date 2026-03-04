# Build translation files on Rails dev server startup
if Rails.env == "development" and defined?(Rails::Server)
  # build the translation files right before starting up in dev:
  puts "=> Building translations from CSV..."
  `bin/translation-csv-to-locale-yamls.mjs`

  # Note: Vite dev server should be started separately via Procfile or manually.
  # Run: `npm run start` or `bin/vite dev` in a separate terminal,
  # or use a process manager like foreman/overmind with Procfile.dev
  puts "=> Rails server ready. Make sure Vite dev server is running on port 3036!"
  puts "   Start it with: npm run start (or use foreman/overmind with Procfile.dev)"
end
