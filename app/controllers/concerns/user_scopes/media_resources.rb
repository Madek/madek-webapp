module Concerns
  module UserScopes
    module MediaResources
      extend ActiveSupport::Concern

      def user_scopes_for_media_resource(resource, user = current_user)
        { parent_collections: \
            auth_policy_scope(user, resource.parent_collections),
          sibling_collections: \
            auth_policy_scope(user, resource.sibling_collections) }
      end

      def user_scopes_for_collection(collection, user = current_user)
        user_scopes_for_media_resource(collection).merge \
          highlighted_media_entries: \
            auth_policy_scope(user, collection.highlighted_media_entries),
          highlighted_collections: \
            auth_policy_scope(user, collection.highlighted_collections),
          child_media_resources: \
            auth_policy_scope(user, collection.child_media_resources),
          child_media_entries: \
            auth_policy_scope(user, collection.media_entries),
          child_collections: \
            auth_policy_scope(user, collection.collections)
      end
    end
  end
end
