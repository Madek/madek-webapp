module Presenters
  module MediaResources
    class RelationCounts < Presenters::Shared::AppResource

      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      def parent_collections_count
        auth_policy_scope(
          @user, @app_resource.parent_collections).count
      end

      def parent_collections_count?
        true
      end

      def child_media_entries_count
        return unless @app_resource.class == Collection
        auth_policy_scope(
          @user, @app_resource.media_entries).count
      end

      def child_media_entries_count?
        @app_resource.class == Collection
      end

      def child_collections_count
        return unless @app_resource.class == Collection
        auth_policy_scope(
          @user, @app_resource.collections).count
      end

      def child_collections_count?
        @app_resource.class == Collection
      end
    end
  end
end
