module Presenters
  module Explore
    class ExploreLoginPage < Presenter
      include ApplicationHelper
      include Presenters::Explore::Modules::MemoizedHelpers

      include Presenters::Explore::Modules::ExploreTeaserEntries
      include Presenters::Explore::Modules::ExploreCatalogSection
      include Presenters::Explore::Modules::ExploreFeaturedContentSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @limit_catalog_context_keys = 3
        @limit_featured_set = 6
        @limit_latest_entries = 12
        @catalog_title = settings.catalog_title
        @featured_set_title = settings.featured_set_title
        @show_all_link = true
      end

      def welcome_message
        {
          title: @settings[:welcome_title],
          text: { __html: markdown(@settings[:welcome_text] || '') }
        }
      end

      def teaser_entries
        teaser_entries_with_presenter \
          Presenters::MediaEntries::MediaEntryTeaserForLogin
      end

      def sections
        [catalog_section,
         featured_set_section,
         latest_media_entries_section].compact
      end

      private

      def latest_media_entries_section
        if latest_media_entries.exists?
          { type: 'thumbnail',
            id: 'latest-media-entries',
            data: \
              { title: I18n.t(:home_page_new_contents),
                url: media_entries_path(list_conf: { order: 'created_at DESC' }),
                list: Presenters::Shared::MediaResource::IndexResources.new(
                  @user,
                  latest_media_entries
                ) },
            show_all_link: false }
        end
      end

      def latest_media_entries
        @latest_media_entries ||= \
          MediaEntry
          .viewable_by_public
          .reorder(created_at: :desc)
          .limit(@limit_latest_entries)
      end

    end
  end
end
