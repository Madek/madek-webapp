module Presenters
  module Users
    class UserDashboard < Presenter
      def initialize(user, list_conf: nil)
        fail 'TypeError!' unless user.is_a?(User)
        @user = user
        @config = ({ order: nil, page: 1, per_page: 1 }).merge(list_conf)
      end

      def unpublished_entries
        presenterify(@user.unpublished_media_entries)
      end

      def content_media_entries
        presenterify(@user.published_media_entries)
      end

      def content_collections
        presenterify(@user.collections)
      end

      def content_filter_sets
        presenterify(@user.filter_sets)
      end

      def latest_imports
        presenterify(@user.published_media_entries)
      end

      def favorite_media_entries
        presenterify(@user.favorite_media_entries)
      end

      def favorite_collections
        presenterify(@user.favorite_collections)
      end

      def favorite_filter_sets
        presenterify(@user.favorite_filter_sets)
      end

      def entrusted_media_entries
        presenterify(MediaEntry.entrusted_to_user(@user))
      end

      def entrusted_collections
        presenterify(Collection.entrusted_to_user(@user))
      end

      def entrusted_filter_sets
        presenterify(FilterSet.entrusted_to_user(@user))
      end

      def groups
        groups = {
          internal: select_groups(@user, :Group, @config),
          external: select_groups(@user, :InstitutionalGroup, @config)
        }.transform_values do |groups|
          groups.map { |group| Presenters::Groups::GroupIndex.new(group, @user) }
        end

        Pojo.new(
          empty?: !(groups[:internal].any? or groups[:external].any?),
          internal: groups[:internal],
          external: groups[:external]
        )
      end

      def used_keywords
        # TODO: fix the need to use local per_page for keywords dashboard section
        per_page = (@config[:per_page] == 1 ? 200 : @config[:per_page])
        @user.used_keywords.page(@config[:page]).per(per_page).map \
          { |k| Presenters::Keywords::KeywordIndex.new(k) }
      end

      private

      def presenterify(resources)
        return if resources.nil?
        Presenters::Shared::MediaResource::MediaResources.new(
          resources, @user, list_conf: @config)
      end

      def select_groups(user, type, config)
        user.groups.where(type: type).page(config[:page]).per(config[:per_page])
      end

    end
  end
end
