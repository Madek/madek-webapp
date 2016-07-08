module Presenters
  module Explore
    class ExploreMainPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers

      include Presenters::Explore::Modules::ExploreTeaserEntries
      include Presenters::Explore::Modules::ExploreNavigation
      include Presenters::Explore::Modules::ExploreCatalogSection
      include Presenters::Explore::Modules::ExploreFeaturedContentSection
      include Presenters::Explore::Modules::ExploreKeywordsSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @limit_catalog_context_keys = 3
        @limit_featured_set = 6
        @limit_keywords = 12
        @catalog_title = settings.catalog_title
        @featured_set_title = settings.featured_set_title
      end

      def teaser_entries
        teaser_entries_with_presenter \
          Presenters::MediaEntries::MediaEntryTeaserForExplore
      end

      def sections
        [catalog_section,
         featured_set_section,
         keywords_section].compact
      end

    end
  end
end
