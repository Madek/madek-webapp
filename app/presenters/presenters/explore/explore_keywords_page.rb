module Presenters
  module Explore
    class ExploreKeywordsPage < Presenter
      include Presenters::Explore::Modules::MemoizedHelpers
      include Presenters::Explore::Modules::ExploreNavigation
      include Presenters::Explore::Modules::ExploreKeywordsSection

      def initialize(user, settings)
        @user = user
        @settings = settings
        @active_section_id = 'keywords'
        @limit_keywords = 200
        @page_title_parts = ['Häufige Schlagworte']
      end

      def sections
        [keywords_section].compact
      end

    end
  end
end
