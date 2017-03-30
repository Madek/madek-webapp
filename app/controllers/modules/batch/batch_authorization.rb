module Modules
  module Batch
    module BatchAuthorization
      extend ActiveSupport::Concern

      def authorize_media_entries_scope!(user, media_entries, policy_scope)
        authorize_batch_scope(
          policy_scope_readable(policy_scope),
          user,
          media_entries,
          policy_scope)
      end

      def authorize_collections_scope!(user, collections, policy_scope)
        authorize_batch_scope(
          policy_scope_readable(policy_scope),
          user,
          collections,
          policy_scope)
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

      def policy_scope_readable(policy_scope)
        policy_scope.name.demodulize.titleize.downcase
      end
    end
  end
end
