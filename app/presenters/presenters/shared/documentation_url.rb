module Presenters
  module Shared
    module DocumentationUrl
      private

      def sanitize_documentation_url(url)
        uri = URI.parse(url)
        uri&.host && url
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
