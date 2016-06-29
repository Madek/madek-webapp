module Presenters
  module Explore
    class ExploreCatalogPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers
      include Presenters::Explore::Modules::ExploreNavigation
      include Presenters::Explore::Modules::ExploreCatalogSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @active_section_id = 'catalog'
        @catalog_title = settings.catalog_subtitle
        @page_title_parts = [settings.catalog_title]
      end

      def sections
        [catalog_section].compact
      end

    end
  end
end
