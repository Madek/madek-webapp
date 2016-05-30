module Presenters
  module Users
    class UserDashboard < Presenter
      def initialize(
            user, user_scopes = {},
            list_conf: nil,
            with_count: true, with_relations: true
      )
        fail 'TypeError!' unless user.is_a?(User)
        @user = user
        @config = { order: nil, page: 1, per_page: 1 }.merge(list_conf)
        @user_scopes = user_scopes
        # FIXME: remove this config when Dashboard is built in Presenter…
        @with_relations = with_relations
        @with_count = with_count
      end

      def new_media_entry_url
        new_media_entry_path
      end

      def new_collection_url
        my_new_collection_path
      end

      def unpublished_entries
        presenterify @user_scopes[:unpublished_media_entries]
      end

      def content_media_entries
        presenterify @user_scopes[:content_media_entries]
      end

      def content_collections
        presenterify @user_scopes[:content_collections]
      end

      def content_filter_sets
        presenterify @user_scopes[:content_filter_sets]
      end

      def latest_imports
        presenterify @user_scopes[:latest_imports]
      end

      def favorite_media_entries
        presenterify @user_scopes[:favorite_media_entries]
      end

      def favorite_collections
        presenterify @user_scopes[:favorite_collections]
      end

      def favorite_filter_sets
        presenterify @user_scopes[:favorite_filter_sets]
      end

      def entrusted_media_entries
        presenterify @user_scopes[:entrusted_media_entries]
      end

      def entrusted_collections
        presenterify @user_scopes[:entrusted_collections]
      end

      def entrusted_filter_sets
        presenterify @user_scopes[:entrusted_filter_sets]
      end

      def groups
        groups = {
          internal: select_groups(:Group),
          external: select_groups(:InstitutionalGroup),
          authentication: select_groups(:AuthenticationGroup)
        }.transform_values do |groups|
          groups.map { |group| Presenters::Groups::GroupIndex.new(group, @user) }
        end

        Pojo.new(
          empty?: !(groups[:internal].any? or groups[:external].any?),
          internal: groups[:internal],
          authentication: groups[:authentication],
          external: groups[:external]
        )
      end

      def used_keywords
        # TODO: fix the need to use local per_page for keywords dashboard section
        per_page = (@config[:per_page] == 1 ? 200 : @config[:per_page])
        @user_scopes[:used_keywords].page(@config[:page]).per(per_page).map \
          { |k| Presenters::Keywords::KeywordIndexWithUsageCount.new(k) }
      end

      private

      def presenterify(resources)
        return if resources.nil?
        Presenters::Shared::MediaResource::MediaResources.new(
          resources,
          @user,
          list_conf: @config,
          with_count: @with_count,
          with_relations: @with_relations)
      end

      def select_groups(type)
        @user_scopes[:user_groups]
          .where(type: type).page(@config[:page]).per(@config[:per_page])
      end

    end
  end
end
