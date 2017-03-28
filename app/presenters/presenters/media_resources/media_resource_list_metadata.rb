module Presenters
  module MediaResources
    class MediaResourceListMetadata < Presenters::Shared::AppResource

      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      def meta_data
        Presenters::MetaData::MetaDataShow.new(@app_resource, @user)
      end

      def relation_counts
        counts = {}

        counts[:parent_collections_count] = auth_policy_scope(
          @user, @app_resource.parent_collections).count

        if @app_resource.class == Collection
          counts[:child_media_entries_count] = auth_policy_scope(
            @user, @app_resource.media_entries).count
          counts[:child_collections_count] = auth_policy_scope(
            @user, @app_resource.collections).count
        end

        counts
      end
    end
  end
end
