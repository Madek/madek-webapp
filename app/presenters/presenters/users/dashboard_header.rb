module Presenters
  module Users
    class DashboardHeader < Presenter

      attr_reader :new_collection

      def initialize(new_collection)
        @new_collection = new_collection
      end

      def new_media_entry_url
        new_media_entry_path
      end

      def new_collection_url
        my_new_collection_path
      end

    end
  end
end
