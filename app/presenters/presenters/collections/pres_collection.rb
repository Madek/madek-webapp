module Presenters
  module Collections
    class PresCollection < Presenter

      def initialize(collection)
        @collection = collection
      end

      def title
        _collection_title(@collection)
      end
    end
  end
end
