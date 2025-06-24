module Presenters
  module Explore
    class ExploreLoginPage < Presenter
      include ApplicationHelper

      def initialize(user, settings, show_login: false)
        @user = user
        @settings = settings
        @catalog_title = localize(settings.catalog_titles)
        @featured_set_title = localize(settings.featured_set_titles)
        @show_login = show_login
      end

      def welcome_message
        {
          title: localize(@settings.welcome_titles),
          text: { __html: markdown(localize(@settings.welcome_texts) || '') }
        }
      end

      def sections
        [
          Presenters::Explore::Modules::ExploreCatalogSection.new(@settings),
          Presenters::Explore::Modules::ExploreLatestSection.new(@user, @settings),
          Presenters::Explore::Modules::ExploreFeaturedContentSection.new(@user, @settings),
          Presenters::Explore::Modules::ExploreKeywordsSection.new,
          Presenters::Explore::Modules::ExploreVocabulariesSection.new(@user, @settings)
        ].compact
      end

      def show_login
        @show_login && !@user
      end
    end
  end
end
