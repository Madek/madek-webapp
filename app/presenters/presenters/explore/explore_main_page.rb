module Presenters
  module Explore
    class ExploreMainPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers

      include Presenters::Explore::Modules::ExploreNavigation
      include Presenters::Explore::Modules::ExploreCatalogSection
      include Presenters::Explore::Modules::ExploreFeaturedContentSection
      include Presenters::Explore::Modules::ExploreKeywordsSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @limit_featured_set = 10
        @limit_keywords = 12
        @catalog_title = settings.catalog_title
        @featured_set_title = settings.featured_set_title
      end

      def sections
        [catalog_section,
         featured_set_section,
         keywords_section].compact
      end

      def teaser_entries
        teaser = Collection.find_by_id(@settings.teaser_set_id)
        return [] unless teaser

        authorized_entries = MediaEntryPolicy::Scope.new(
          @user, teaser.media_entries).resolve

        Presenters::MediaEntries::MediaEntries.new(authorized_entries,
                                                   @user,
                                                   list_conf: {})
      end
    end
  end
end
