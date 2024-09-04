module UserScopes
  module MediaResources
    extend ActiveSupport::Concern

    def user_scopes_for_media_resource(resource, user = current_user)
      { parent_collections: \
          auth_policy_scope(
            user,
            resource.parent_collections),
        sibling_collections: \
          auth_policy_scope(
            user,
            resource.sibling_collections) }
    end

    def user_scopes_for_collection(collection, user = current_user)
      special_scope = active_workflow_scope(collection)

      child_media_entries_scope = auth_policy_scope(user,
                                                    collection.media_entries,
                                                    special_scope)
      child_collections_scope = auth_policy_scope(user,
                                                  collection.collections)
      child_media_resources_scope =
        MediaResource.unified_scope([child_media_entries_scope, child_collections_scope],
                                    collection.id)

      user_scopes_for_media_resource(collection).merge(
        highlighted_media_entries: auth_policy_scope(user, collection.highlighted_media_entries),
        highlighted_collections: auth_policy_scope(user, collection.highlighted_collections),
        child_media_entries: child_media_entries_scope,
        child_collections: child_collections_scope,
        child_media_resources: child_media_resources_scope
      )
    end

    private

    def active_workflow_scope(collection)
      collection.part_of_workflow?(active: true) ? MediaResourcePolicy::ActiveWorkflowScope : nil
    end
  end
end
