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
        mr_presenter_for @app_resource.media_resources
      end

      def latest_imports
        mr_presenter_for @app_resource.created_media_entries
      end

      def favorites
        mr_presenter_for @app_resource.favorite_media_resources
      end

      def entrusted_content
        mr_presenter_for MediaResource.entrusted_to_user(@app_resource)
      end

      def groups
        @app_resource.groups.page(@page).per(@per_page)
          .map do |group|
            Presenters::Groups::GroupShow.new(group, @user)
          end
      end

      private

      def mr_presenter_for(media_resources)
        Presenters::Shared::MediaResources::MediaResources.new \
          @app_resource,
          media_resources: media_resources,
          order: @order,
          page: @page,
          per_page: @per_page
      end
    end
  end
end
