module Modules
  module Batch
    module BatchShared
      extend ActiveSupport::Concern

      private

      def presenter_values(params, policy_scope)
        return_to = params.require(:return_to)

        auth_authorize User, :logged_in?

        resource_ids = params.require(:resource_id)

        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        collection_ids = resource_ids_to_uuids(resource_ids, 'Collection')

        authorize_media_entries(media_entry_ids, policy_scope)
        authorize_collections(collection_ids, policy_scope)

        {
          user: current_user,
          resource_ids: resource_ids,
          return_to: return_to
        }
      end

      def read_media_entries(resource_ids, policy_scope)
        media_entry_ids = resource_ids_to_uuids(resource_ids, 'MediaEntry')
        authorize_media_entries(media_entry_ids, policy_scope)
      end

      def read_collections(resource_ids, policy_scope)
        collection_ids = resource_ids_to_uuids(resource_ids, 'Collection')
        authorize_collections(collection_ids, policy_scope)
      end

      def read_parent_collection(
        parent_collection_id, skip_parent_authorization)

        return unless parent_collection_id

        parent_collection = Collection.unscoped.find(parent_collection_id)
        # Cannot authorize for clipboard, since default scope would say
        # define_access_methods exists? = false
        unless skip_parent_authorization
          auth_authorize parent_collection, "#{action_name}?".to_sym
        end
        parent_collection
      end

      def authorize_and_read_batch_resources(
        params,
        parent_collection_id,
        policy_scope,
        skip_parent_authorization: false)

        auth_authorize User, :logged_in?

        resource_ids = params.require(:resource_id)

        {
          media_entries: read_media_entries(resource_ids, policy_scope),
          collections: read_collections(resource_ids, policy_scope),
          parent_collection: read_parent_collection(
            parent_collection_id,
            skip_parent_authorization)
        }
      end

      def resource_ids_to_uuids(resource_ids, type)
        resource_ids.select do |resource_id|
          resource_id[:type] == type
        end.map do |resource_id|
          resource_id[:uuid]
        end
      end

      def authorize_media_entries(media_entry_ids, policy_scope)
        if media_entry_ids.empty?
          return []
        end
        media_entries = MediaEntry.unscoped.where(id: media_entry_ids)
        authorize_media_entries_scope!(current_user, media_entries, policy_scope)
        media_entries
      end

      def authorize_collections(collection_ids, policy_scope)
        if collection_ids.empty?
          return []
        end
        collections = Collection.unscoped.where(id: collection_ids)
        authorize_collections_scope!(current_user, collections, policy_scope)
        collections
      end

      def add_transaction(parent_collection, media_entries, collections)
        media_entries.each do |media_entry|
          # Do not add if already in the collection.
          Arcs::CollectionMediaEntryArc.find_or_create_by(
            collection: parent_collection, media_entry: media_entry)
        end
        collections.each do |collection|
          # Do not add to itself.
          next if parent_collection.id == collection.id
          # Do not add if already in the collection.
          Arcs::CollectionCollectionArc.find_or_create_by(
            parent: parent_collection, child: collection)
        end
      end

      def remove_transaction(parent_collection, media_entries, collections)
        media_entries.each do |media_entry|
          Arcs::CollectionMediaEntryArc.where(
            collection: parent_collection, media_entry: media_entry).delete_all
        end
        collections.each do |collection|
          Arcs::CollectionCollectionArc.where(
            parent: parent_collection, child: collection).delete_all
        end
      end
    end
  end
end
