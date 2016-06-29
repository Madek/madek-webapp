module Presenters
  module Explore
    class ExploreLoginPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers
      include Presenters::Explore::Modules::ExploreCatalogSection
      include Presenters::Explore::Modules::ExploreFeaturedContentSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @limit_featured_set = 6
        @catalog_title = settings.catalog_title
        @featured_set_title = settings.featured_set_title
      end

      def teaser_entries
        teaser = Collection.find_by_id(@settings.teaser_set_id)
        return [] unless teaser
        Presenters::MediaEntries::MediaEntries.new(
          teaser.media_entries, @user, list_conf: {})
      end

      def sections
        [catalog_section,
         featured_set_section,
         latest_media_entries_section].compact
      end

      private

      def latest_media_entries_section
        unless latest_media_entries.blank?
          { type: 'thumbnail',
            data: \
              { title: 'Latest media entries',
                url: media_entries_path(list_conf: { order: 'created_at DESC' }),
                list: Presenters::MediaEntries::MediaEntries.new(
                  @latest_media_entries,
                  nil,
                  list_conf: {}) },
            show_all_link: false }
        end
      end

      def latest_media_entries
        @latest_media_entries = \
          MediaEntry
          .viewable_by_public
          .order('media_entries.created_at DESC')
          .limit(10)
      end

    end
  end
end
