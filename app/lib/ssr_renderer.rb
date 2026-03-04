# Custom SSR renderer using ExecJS, replacing react-rails gem.
# Designed so the backend can be swapped to Node.js HTTP service later.
#
# Usage in views (identical to before):
#   SsrRenderer.render('Views.Dashboard', { get: presenter_data })
#
# The backend is swappable:
#   - Phase 1 (now): ExecJsBackend (same as react-rails internally)
#   - Phase 2 (future): NodeBackend (HTTP call to Express/Fastify service)

module SsrRenderer
  class Error < StandardError; end

  def self.render(component_name, props)
    backend.render(component_name, props)
  end

  # Call this to force re-creation of the backend (e.g., when SSR bundle changes)
  def self.reset!
    @backend = nil
  end

  private

  def self.backend
    @backend ||= ExecJsBackend.new
  end
end
