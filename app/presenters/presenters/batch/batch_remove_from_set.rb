module Presenters
  module Batch
    class BatchRemoveFromSet < Presenter

      def initialize(
        user,
        parent_collection_id,
        media_entry_ids,
        collection_ids,
        return_to)
        @user = user
        @parent_collection_id = parent_collection_id
        @media_entry_ids = media_entry_ids
        @collection_ids = collection_ids
        @return_to = return_to
      end

      attr_accessor :media_entry_ids
      attr_accessor :collection_ids
      attr_accessor :return_to
      attr_accessor :parent_collection_id

      def batch_count
        media_entries_count + collections_count
      end

      def media_entries_count
        @media_entry_ids.length
      end

      def collections_count
        @collection_ids.length
      end

      def parent_collection_title
        Presenters::Collections::CollectionIndex.new(
          Collection.find(@parent_collection_id),
          @user).title
      end

      def batch_remove_from_set_url
        batch_remove_from_set_path
      end
    end
  end
end
