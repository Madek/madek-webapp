module Presenters
  module Users
    class UserDashboard < Presenters::Shared::AppResource
      def initialize(user, order: nil, page: 1, per_page: nil)
        @user = user
        super(user)
        @order = order
        @page = page
        @per_page = per_page
      end

      def content
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries
              .new(@app_resource,
                   @app_resource.media_entries,
                   order: @order,
                   page: @page,
                   per_page: @per_page),
          collections: \
            Presenters::Collections::Collections
              .new(@app_resource,
                   @app_resource.collections,
                   order: @order,
                   page: @page,
                   per_page: @per_page),
          filter_sets: \
            Presenters::FilterSets::FilterSets
              .new(@app_resource,
                   @app_resource.filter_sets,
                   order: @order,
                   page: @page,
                   per_page: @per_page)
        )
      end

      def latest_imports
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries
              .new(@app_resource,
                   @app_resource.created_media_entries,
                   order: @order,
                   page: @page,
                   per_page: @per_page)
        )
      end

      def favorites
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries
              .new(@app_resource,
                   @app_resource.favorite_media_entries,
                   order: @order,
                   page: @page,
                   per_page: @per_page),
          collections: \
            Presenters::Collections::Collections
              .new(@app_resource,
                   @app_resource.favorite_collections,
                   order: @order,
                   page: @page,
                   per_page: @per_page),
          filter_sets: \
            Presenters::FilterSets::FilterSets
              .new(@app_resource,
                   @app_resource.favorite_filter_sets,
                   order: @order,
                   page: @page,
                   per_page: @per_page)
        )
      end

      def entrusted_content
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries
              .new(@app_resource,
                   MediaEntry.entrusted_to_user(@app_resource),
                   order: @order,
                   page: @page,
                   per_page: @per_page),
          collections: \
            Presenters::Collections::Collections
              .new(@app_resource,
                   Collection.entrusted_to_user(@app_resource),
                   order: @order,
                   page: @page,
                   per_page: @per_page),
          filter_sets: \
            Presenters::FilterSets::FilterSets
              .new(@app_resource,
                   FilterSet.entrusted_to_user(@app_resource),
                   order: @order,
                   page: @page,
                   per_page: @per_page)
        )
      end

      def groups
        groups = {
          internal: @app_resource.groups
            .where(type: :Group)
            .page(@page).per(@per_page),
          external: @app_resource.groups
            .where(type: :InstitutionalGroup)
            .page(@page).per(@per_page)
        }.map do |key, groups|
          [key, groups.map { |group| Presenters::Groups::GroupIndex.new(group) }]
        end.to_h

        Pojo.new(
          empty?: !(groups[:internal].any? and groups[:external].any?),
          internal: groups[:internal],
          external: groups[:external]
        )
      end
    end
  end
end
