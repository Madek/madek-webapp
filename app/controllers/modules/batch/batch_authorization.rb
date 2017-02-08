module Modules
  module Batch
    module BatchAuthorization
      extend ActiveSupport::Concern

      def authorize_media_entries_for_view!(user, media_entries)
        authorize_batch_scope('view all resources', user, media_entries)
      end

      def authorize_collections_for_view!(user, collections)
        authorize_batch_scope('view all resources', user, collections)
      end

      def authorize_resources_for_permissions_batch_edit!(user, resources)
        authorize_batch_scope(
          'edit permissions of all resources', user, resources,
          MediaResourcePolicy::ManageableScope)
      end

      private

      def authorize_batch_scope(action_name, user, resources, scope = nil)
        authorized_resources = auth_policy_scope(user, resources, scope)
        if resources.count != authorized_resources.count
          raise Errors::ForbiddenError, "Not allowed to #{action_name}!"
        end
      end

    end
  end
end
