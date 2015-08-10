module Presenters
  module Users
    class UserDashboard < Presenter
      def initialize(user, order: nil, page: 1, per_page: nil)
        @user = user
        @order = order
        @page = page
        @per_page = per_page
      end

      def unpublished
        wrap_in_presenters_pojo([
          @user.unpublished_media_entries,
          nil,
          nil
        ])
      end

      def content
        wrap_in_presenters_pojo([
          @user.published_media_entries,
          @user.collections,
          @user.filter_sets
        ])
      end

      def latest_imports
        wrap_in_presenters_pojo([
          @user.published_media_entries,
          nil,
          nil
        ])
      end

      def favorites
        wrap_in_presenters_pojo([
          @user.favorite_media_entries,
          @user.favorite_collections,
          @user.favorite_filter_sets
        ])
      end

      def entrusted_content
        wrap_in_presenters_pojo([
          MediaEntry.entrusted_to_user(@user),
          Collection.entrusted_to_user(@user),
          FilterSet.entrusted_to_user(@user)
        ])
      end

      def groups
        groups = {
          internal: @user.groups
            .where(type: :Group)
            .page(@page).per(@per_page),
          external: @user.groups
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
        @user.used_keywords.map \
          { |k| Presenters::Keywords::KeywordIndex.new(k) }
      end

      private

      def wrap_in_presenters_pojo(resources)
        user = @user

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
