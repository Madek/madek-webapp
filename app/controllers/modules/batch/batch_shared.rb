module Modules
  module Batch
    module BatchShared
      extend ActiveSupport::Concern

      private

      def presenter_values(params)
        return_to = params.require(:return_to)

        auth_authorize MediaEntry, :logged_in?

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

      def action_values(
        params,
        parent_collection_id,
        skip_parent_authorization: false)

        auth_authorize MediaEntry, :logged_in?

        parent_collection = Collection.unscoped.find(parent_collection_id)
        # Cannot authorize for clipboard, since default scope would say
        # define_access_methods exists? = false
        unless skip_parent_authorization
          auth_authorize parent_collection, "#{action_name}?".to_sym
        end

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

      def add_transaction(parent_collection, media_entries, collections)
        existing = parent_collection.media_entries
          .rewhere(is_published: [true, false]).reload
        media_entries.each do |media_entry|
          # Do not add if already in the collection.
          next if existing.include? media_entry
          parent_collection.media_entries << media_entry
        end
        existing = parent_collection.collections.reload
        collections.each do |collection|
          # Do not add if already in the collection.
          next if existing.include? collection
          # Do not add to itself.
          next if parent_collection.id == collection.id
          parent_collection.collections << collection
        end
      end

      def remove_transaction(parent_collection, media_entries, collections)
        to_remove_media_entries = media_entries.select do |media_entry|
          parent_collection.media_entries.with_unpublished.include? media_entry
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
