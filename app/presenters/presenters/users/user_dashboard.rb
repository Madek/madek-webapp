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
        wrap_in_presenters_pojo([
          @app_resource.media_entries,
          @app_resource.collections,
          @app_resource.filter_sets
        ])
      end

      def latest_imports
        wrap_in_presenters_pojo([
          @app_resource.created_media_entries,
          nil,
          nil
        ])
      end

      def favorites
        wrap_in_presenters_pojo([
          @app_resource.favorite_media_entries,
          @app_resource.favorite_collections,
          @app_resource.favorite_filter_sets
        ])
      end

      def entrusted_content
        wrap_in_presenters_pojo([
          MediaEntry.entrusted_to_user(@app_resource),
          Collection.entrusted_to_user(@app_resource),
          FilterSet.entrusted_to_user(@app_resource)
        ])
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
          empty?: !(groups[:internal].any? or groups[:external].any?),
          internal: groups[:internal],
          external: groups[:external]
        )
      end

      def used_keywords
        @app_resource.used_keywords.map \
          { |k| Presenters::Keywords::KeywordIndex.new(k) }
      end

      private

      def wrap_in_presenters_pojo(resources)
        user = @app_resource

        media_entries, collections, filter_sets = [
          [resources.first, Presenters::MediaEntries::MediaEntries],
          [resources.second, Presenters::Collections::Collections],
          [resources.third, Presenters::FilterSets::FilterSets]
        ].map do |collection, presenter|
          collection.presence && presenter.new(
            user, collection,
            order: @order, page: @page, per_page: @per_page
          )
        end

        Pojo.new(
          media_entries: media_entries,
          collections: collections,
          filter_sets: filter_sets,
          empty?: !([media_entries, collections, filter_sets]
                      .map { |c| c.try(:any?) }.reduce { |a, e| a or e })
        )
      end
    end
  end
end
