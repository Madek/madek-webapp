module Presenters
  module Explore
    class ExploreMainPage < Presenter
      include Presenters::Explore::Modules::ExplorePageCommon

      def initialize(user, settings)
        @user = user
        @settings = settings
        @limit_featured_set = 10
        @limit_keywords = 12
        @catalog_title = settings.catalog_title
        @featured_set_title = settings.featured_set_title
      end

      def sections
        [
          { type: 'catalog',
            data: catalog_overview,
            show_all_link: true },
          { type: 'thumbnail',
            data: featured_set_overview,
            show_all_link: true },
          { type: 'keyword',
            data: keywords,
            show_all_link: true }
        ]
      end

      def teaser_entries
        teaser = Collection.find_by(id: @settings.teaser_set_id)
        return unless teaser

        authorized_entries = MediaEntryPolicy::Scope.new(
          @user, teaser.media_entries).resolve

        Presenters::MediaEntries::MediaEntries.new(authorized_entries,
                                                   @user,
                                                   list_conf: {})
      end
    end
  end
end
