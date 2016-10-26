module Concerns
  module UserScopes
    module MediaResources
      extend ActiveSupport::Concern

      def user_scopes_for_media_resource(resource)
        { parent_collections: \
            policy_scope(resource.parent_collections),
          sibling_collections: \
            policy_scope(resource.sibling_collections) }
      end

      def user_scopes_for_collection(collection)
        user_scopes_for_media_resource(collection).merge \
          highlighted_media_entries: \
            policy_scope(collection.highlighted_media_entries),
          highlighted_collections: \
            policy_scope(collection.highlighted_collections),
          child_media_resources: \
            Shared::MediaResources::MediaResourcePolicy::Scope.new(
              current_user,
              collection.child_media_resources).resolve,
          child_media_entries: \
            MediaEntryPolicy::Scope.new(
              current_user,
              collection.media_entries).resolve,
          child_collections: \
            CollectionPolicy::Scope.new(
              current_user,
              collection.collections).resolve
      end
    end
  end
end
