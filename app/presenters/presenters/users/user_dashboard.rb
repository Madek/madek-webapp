module Presenters
  module Users
    class UserDashboard < Presenter
      def initialize(
            user, user_scopes,
            dashboard_header,
            list_conf: nil,
            with_count: true,
            action: nil
      )
        fail 'TypeError!' unless user.is_a?(User)
        @user = user
        @config = { page: 1 }.merge(list_conf)
        @user_scopes = user_scopes
        @dashboard_header = dashboard_header
        # FIXME: remove this config when Dashboard is built in Presenter…
        @with_count = with_count
        @action = action
      end

      attr_reader :dashboard_header

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
        is_section_view = (@action && @action == 'dashboard_section')
        per_page = (is_section_view ? 200 : 24)
        @user_scopes[:used_keywords].page(1).per(per_page).map \
          { |k| Presenters::Keywords::KeywordIndexWithUsageCount.new(k) }
      end

      private

      def presenterify(resources)
        return if resources.nil?
        Presenters::Shared::MediaResource::MediaResources.new(
          resources,
          @user,
          list_conf: @config,
          with_count: @with_count)
      end

      def select_groups(type)
        @user_scopes[:user_groups]
          .where(type: type).page(@config[:page]).per(@config[:per_page])
      end

    end
  end
end
