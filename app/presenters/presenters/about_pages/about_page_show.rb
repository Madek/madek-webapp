module Presenters
  module AboutPages
    class AboutPageShow < Presenter
      include ApplicationHelper

      def initialize(raw_text)
        @raw_text = raw_text
      end

      def raw_html
        markdown(@raw_text)
      end

    end
  end
end
