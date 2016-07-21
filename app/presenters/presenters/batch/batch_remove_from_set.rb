module Presenters
  module Batch
    class BatchRemoveFromSet < Presenter

      def initialize(initial_values)
        @user = initial_values[:user]
        @parent_collection_id = initial_values[:parent_collection_id]
        @resource_ids = initial_values[:resource_ids]
        @return_to = initial_values[:return_to]
      end

      attr_accessor :resource_ids
      attr_accessor :return_to
      attr_accessor :parent_collection_id

      def batch_count
        @resource_ids.length
      end

      def media_entries_count
        @resource_ids.select do |resource_id|
          resource_id[:type] == 'MediaEntry'
        end.length
      end

      def collections_count
        @resource_ids.select do |resource_id|
          resource_id[:type] == 'Collection'
        end.length
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
