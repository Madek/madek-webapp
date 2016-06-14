module Presenters
  module Explore
    class ExploreKeywordsPage < Presenter
      include Presenters::Explore::Modules::ExplorePageCommon

      def initialize(user, settings)
        @user = user
        @settings = settings
        @active_section_id = 'keywords'
        @limit_keywords = 200
        @page_title_parts = ['Häufige Schlagworte']
      end

      def sections
        [
          { type: 'keyword', data: keywords, show_all_link: false }
        ]
      end

    end
  end
end
