module Modules
  module Batch
    module BatchRemoveFromSet
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization

      def batch_ask_remove_from_set
        return_to = params.require(:return_to)

        authorize MediaEntry, :logged_in?

        parent_collection_id = params.require(:parent_collection_id)

        resource_ids = params.require(:resource_id)

        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        collection_ids = resource_ids_to_uuids(resource_ids, 'Collection')

        authorize_media_entries(media_entry_ids)
        authorize_collections(collection_ids)

        @get = Presenters::Batch::BatchRemoveFromSet.new(
          current_user,
          parent_collection_id,
          media_entry_ids,
          collection_ids,
          return_to
        )

        respond_with(@get, template: 'batch/batch_ask_remove_from_set')
      end

      def batch_remove_from_set
        return_to = params.require(:return_to)

        authorize MediaEntry, :logged_in?

        parent_collection_id = params.require(:parent_collection_id)
        parent_collection = Collection.find(parent_collection_id)
        authorize parent_collection

        media_entries = []
        if params[:media_entry_id]
          media_entry_ids = params[:media_entry_id]
          media_entries = authorize_media_entries(media_entry_ids)
        end

        collections = []
        if params[:collection_id]
          collection_ids = params[:collection_id]
          collections = authorize_collections(collection_ids)
        end

        remove_transaction(parent_collection, media_entries, collections)

        redirect_to(return_to)
      end

      private

      def resource_ids_to_uuids(resource_ids, type)
        resource_ids.select do |resource_id|
          resource_id[:type] == type
        end.map do |resource_id|
          resource_id[:uuid]
        end
      end

      def authorize_media_entries(media_entry_ids)
        media_entries = MediaEntry.unscoped.where(id: media_entry_ids)
        authorize_media_entries_for_view!(current_user, media_entries)
        media_entries
      end

      def authorize_collections(collection_ids)
        collections = Collection.unscoped.where(id: collection_ids)
        authorize_collections_for_view!(current_user, collections)
        collections
      end

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
