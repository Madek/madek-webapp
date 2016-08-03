module Modules
  module Batch
    module BatchShared
      extend ActiveSupport::Concern

      private

      def presenter_values(params)
        return_to = params.require(:return_to)

        authorize MediaEntry, :logged_in?

        resource_ids = params.require(:resource_id)

        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        collection_ids = resource_ids_to_uuids(resource_ids, 'Collection')

        authorize_media_entries(media_entry_ids)
        authorize_collections(collection_ids)

        {
          user: current_user,
          resource_ids: resource_ids,
          return_to: return_to
        }
      end

      def action_values(params, parent_collection_id)
        authorize MediaEntry, :logged_in?

        parent_collection = Collection.find(parent_collection_id)
        authorize parent_collection

        resource_ids = params.require(:resource_id)

        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        collection_ids = resource_ids_to_uuids(resource_ids, 'Collection')

        media_entries = authorize_media_entries(media_entry_ids)
        collections = authorize_collections(collection_ids)

        {
          parent_collection: parent_collection,
          media_entries: media_entries,
          collections: collections
        }
      end

      def resource_ids_to_uuids(resource_ids, type)
        resource_ids.select do |resource_id|
          resource_id[:type] == type
        end.map do |resource_id|
          resource_id[:uuid]
        end
      end

      def authorize_media_entries(media_entry_ids)
        if media_entry_ids.empty?
          return []
        end
        media_entries = MediaEntry.unscoped.where(id: media_entry_ids)
        authorize_media_entries_for_view!(current_user, media_entries)
        media_entries
      end

      def authorize_collections(collection_ids)
        if collection_ids.empty?
          return []
        end
        collections = Collection.unscoped.where(id: collection_ids)
        authorize_collections_for_view!(current_user, collections)
        collections
      end
    end
  end
end
