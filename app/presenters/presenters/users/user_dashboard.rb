module Presenters
  module Users
    class UserDashboard < Presenters::Shared::AppResource
      def initialize(user, order: nil, page: nil, per: nil)
        super(user)
        @order = order
        @page = page.to_i
        @per = per
      end

      def content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.media_entries,
          collections: @app_resource.collections,
          filter_sets: @app_resource.filter_sets,
          order: @order,
          page: @page,
          per: @per
      end

      def latest_imports
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.created_media_entries,
          order: @order,
          page: @page,
          per: @per
      end

      def favorites
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: @app_resource.favorite_media_entries,
          collections: @app_resource.favorite_collections,
          filter_sets: @app_resource.favorite_filter_sets,
          page: @page,
          per: @per
      end

      def entrusted_content
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_entries: MediaEntry.entrusted_to_user(@app_resource),
          collections: Collection.entrusted_to_user(@app_resource),
          filter_sets: FilterSet.entrusted_to_user(@app_resource),
          order: @order,
          page: @page,
          per: @per
      end

      def groups
        paginate(@app_resource.groups, @page, @per)
          .map do |group|
            Presenters::Groups::GroupShow
              .new(group, @user)
          end
      end
    end
  end
end
