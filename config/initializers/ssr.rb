# Auto-reload SSR context when bundle changes in development
if Rails.env.development?
  ssr_bundle_path = Rails.root.join(
    "public/assets/bundles/dev-bundle-react-server-side.js"
  ).to_s

  # Watch the SSR bundle file for changes
  Rails.application.config.watchable_files << ssr_bundle_path

  # Reset the SSR renderer when files change (forces re-read of bundle)
  ActiveSupport::Reloader.to_prepare do
    SsrRenderer.reset!
  end
end
