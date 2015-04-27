module Presenters
  module Users
    class UserDashboard < Presenters::Shared::AppResource
      def initialize(user, order: nil, page: 1, per_page: nil)
        super(user)
        @order = order
        @page = page
        @per_page = per_page
      end

      def content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.media_entries,
          collections: @app_resource.collections,
          filter_sets: @app_resource.filter_sets,
          order: @order,
          page: @page,
          per_page: @per_page
      end

      def latest_imports
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.created_media_entries,
          order: @order,
          page: @page,
          per_page: @per_page
      end

      def favorites
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.favorite_media_entries,
          collections: @app_resource.favorite_collections,
          filter_sets: @app_resource.favorite_filter_sets,
          page: @page,
          per_page: @per_page
      end

      def entrusted_content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: MediaEntry.entrusted_to_user(@app_resource),
          collections: Collection.entrusted_to_user(@app_resource),
          filter_sets: FilterSet.entrusted_to_user(@app_resource),
          order: @order,
          page: @page,
          per_page: @per_page
      end

      def groups
        @app_resource.groups.page(@page).per(@per_page)
          .map do |group|
            Presenters::Groups::GroupShow.new(group, @user)
          end
      end
    end
  end
end
