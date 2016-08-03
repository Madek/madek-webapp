module Modules
  module Batch
    module BatchRemoveFromSet
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchShared

      def batch_ask_remove_from_set
        presenter_values = presenter_values(params)

        parent_collection_id = params.require(:parent_collection_id)
        presenter_values[:parent_collection_id] = parent_collection_id

        @get = Presenters::Batch::BatchRemoveFromSet.new(presenter_values)
        respond_with(@get, template: 'batch/batch_ask_remove_from_set')
      end

      def batch_remove_from_set
        return_to = params.require(:return_to)

        action_values = action_values(
          params,
          params.require(:parent_collection_id))

        remove_transaction(
          action_values[:parent_collection],
          action_values[:media_entries],
          action_values[:collections])

        redirect_to(return_to)
      end

      private

      def remove_transaction(parent_collection, media_entries, collections)
        ActiveRecord::Base.transaction do
          to_remove_media_entries = media_entries.select do |media_entry|
            parent_collection.media_entries.include? media_entry
          end
          to_remove_media_entries.each do |media_entry|
            parent_collection.media_entries.delete(media_entry)
          end

          to_remove_collections = collections.select do |collection|
            parent_collection.collections.include? collection
          end
          to_remove_collections.each do |collection|
            parent_collection.collections.delete(collection)
          end
        end
      end
    end
  end
end
