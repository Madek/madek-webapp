module Presenters
  module Explore
    class ExploreFeaturedContentPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers
      include Presenters::Explore::Modules::ExploreNavigation
      include Presenters::Explore::Modules::ExploreFeaturedContentSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @active_section_id = 'featured_set'
        @limit_featured_set = 1000
        @featured_set_title = settings.featured_set_subtitle
        @page_title_parts = [settings.featured_set_title]
      end

      def sections
        [featured_set_section].compact
      end

    end
  end
end
