module Presenters
  module Collections
    class CollectionNew < Presenter

      attr_accessor :error

      def submit_url
        collections_path
      end

      def cancel_url
        my_dashboard_path
      end

    end
  end
end
