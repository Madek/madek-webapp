module Presenters
  module Explore
    class ExploreFeaturedContentPage < Presenter
      include Presenters::Explore::Modules::ExplorePageCommon

      def initialize(user, settings)
        @user = user
        @settings = settings
        @active_section_id = 'featured_set'
        @limit_featured_set = 1000
        @featured_set_title = settings.featured_set_subtitle
        @page_title_parts = [settings.featured_set_title]
      end

      def sections
        [
          { type: 'thumbnail', data: featured_set_overview, show_all_link: false }
        ]
      end

    end
  end
end
