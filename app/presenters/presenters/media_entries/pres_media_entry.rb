module Presenters
  module MediaEntries
    class PresMediaEntry < Presenter

      def initialize(media_entry)
        @media_entry = media_entry
      end

      def title
        _media_entry_title(@media_entry)
      end
    end
  end
end
