require "connection_pool"

module SsrRenderer
  class ExecJsBackend
    def initialize
      @pool = ConnectionPool.new(
        size: pool_size,
        timeout: render_timeout
      ) { create_context }
    end

    # Render a React component to HTML string.
    # component_name: e.g., "Views.Dashboard" (without "UI." prefix)
    # props: Hash of component props (already serialized, no Presenter objects)
    def render(component_name, props)
      @pool.with do |context|
        context.call("renderComponent", component_name, props)
      end
    rescue => e
      Rails.logger.error("[SSR] Render failed for #{component_name}: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n")) if e.backtrace
      "" # Fall back to client-only rendering (empty string = no server HTML)
    end

    private

    def create_context
      js = []
      js << FrontendAppConfig.to_js
      js << bundle_contents
      js << render_function_js
      ExecJS.compile(js.join("\n;\n"))
    end

    def bundle_contents
      File.read(bundle_path)
    end

    def bundle_path
      if Rails.env.development?
        Rails.root.join("public/assets/bundles/dev-bundle-react-server-side.js")
      else
        Rails.root.join("public/assets/bundles/bundle-react-server-side.js")
      end
    end

    # JavaScript function that the ExecJS context exposes.
    # It resolves a dotted component name (e.g., "Views.My.Uploader")
    # from the global UI object and renders it to an HTML string.
    def render_function_js
      <<~JS
        function renderComponent(name, props) {
          var component = name.split('.').reduce(function(obj, key) {
            return obj && obj[key];
          }, UI);
          if (!component) {
            throw new Error('Component not found: UI.' + name);
          }
          var element = React.createElement(component, props);
          return ReactDOMServer.renderToString(element);
        }
      JS
    end

    def pool_size
      Rails.configuration.x.ssr_pool_size ||
        (Rails.env.production? ? 12 : 1)
    end

    def render_timeout
      Rails.configuration.x.ssr_timeout || 10
    end
  end
end
