module Presenters
  module Explore
    class ExploreCatalogPage < Presenter
      include Presenters::Explore::Modules::ExplorePageCommon

      def initialize(user, settings)
        @user = user
        @settings = settings
        @active_section_id = 'catalog'
        @catalog_title = settings.catalog_subtitle
        @page_title_parts = [settings.catalog_title]
      end

      def sections
        [
          { type: 'catalog', data: catalog_overview, show_all_link: false }
        ]
      end

    end
  end
end
