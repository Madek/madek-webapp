module Presenters
  module AboutPages
    class AboutPageShow < Presenter
      include ApplicationHelper

      def initialize(raw_text, static_page = nil)
        raise 'TypeError!' if static_page&.is_a?(::StaticPage) == false
        @raw_text = raw_text
        @static_page = static_page
      end

      def raw_html
        markdown(@raw_text)
      end

      def title
        @static_page&.name&.titleize
      end
    end
  end
end
