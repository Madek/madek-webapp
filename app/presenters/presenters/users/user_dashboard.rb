module Presenters
  module Users
    class UserDashboard < Presenters::Shared::AppResource

      def initialize(user, order: nil, limit: nil)
        super(user)
        @limit = limit
        @order = order
      end

      def content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.media_entries,
          collections: @app_resource.collections,
          filter_sets: @app_resource.filter_sets,
          order: @order,
          limit: @limit
      end

      def latest_imports
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.created_media_entries,
          order: @order,
          limit: @limit
      end

      def favorites
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.favorite_media_entries,
          collections: @app_resource.favorite_collections,
          filter_sets: @app_resource.favorite_filter_sets,
          limit: @limit
      end

      def entrusted_content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: MediaEntry.entrusted_to_user(@app_resource),
          collections: Collection.entrusted_to_user(@app_resource),
          filter_sets: FilterSet.entrusted_to_user(@app_resource),
          order: @order,
          limit: @limit
      end

      def groups
        @app_resource.groups.limit(@limit).map do |group|
          Presenters::Groups::GroupShow
            .new(group, @user)
        end
      end
    end
  end
end
