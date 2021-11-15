module Presenters
  module Collections
    class CollectionNew < Presenter

      attr_reader :error

      delegate :title, to: :parent_collection, prefix: true, allow_nil: true

      def initialize(error:, parent_collection:)
        @error = error
        @parent_collection = parent_collection
      end

      def submit_url
        collections_path(parent_id: parent_collection&.id)
      end

      def cancel_url
        my_dashboard_path
      end

      private

      attr_reader :parent_collection
    end
  end
end
