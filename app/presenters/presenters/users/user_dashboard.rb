module Presenters
  module Users
    class UserDashboard < Presenters::Shared::AppResource

      def initialize(user, limit)
        super(user)
        @limit = limit
      end

      def content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries:
            @app_resource.media_entries.reorder('created_at DESC').limit(@limit),
          collections:
            @app_resource.collections.reorder('created_at DESC').limit(@limit),
          filter_sets:
            @app_resource.filter_sets.reorder('created_at DESC').limit(@limit)
      end

      def latest_imports
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries:
            @app_resource
              .created_media_entries
              .reorder('created_at DESC')
              .limit(@limit)
      end

      def favorites
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries:
            @app_resource.favorite_media_entries.limit(@limit),
          collections:
            @app_resource.favorite_collections.limit(@limit),
          filter_sets:
            @app_resource.favorite_filter_sets.limit(@limit)
      end

      def entrusted_content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries:
            MediaEntry.entrusted_to_user(@app_resource)
              .reorder('created_at DESC').limit(@limit),
          collections:
            Collection.entrusted_to_user(@app_resource)
              .reorder('created_at DESC').limit(@limit),
          filter_sets:
            FilterSet.entrusted_to_user(@app_resource)
              .reorder('created_at DESC').limit(@limit)
      end

      def groups
        @app_resource.groups.limit(4).map do |group|
          Presenters::Groups::GroupShow
            .new(group, @user)
        end
      end
    end
  end
end
