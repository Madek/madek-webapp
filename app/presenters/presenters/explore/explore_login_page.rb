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
          catalog_section,
          latest_section,
          featured_content_section,
          keywords_section,
          vocabularies_section
        ].compact
      end

      def catalog_section
        Presenters::Explore::Modules::ExploreCatalogSection.new(@settings)
      end

      def latest_section
        Presenters::Explore::Modules::ExploreLatestSection.new(@user, @settings)
      end

      def featured_content_section
        Presenters::Explore::Modules::ExploreFeaturedContentSection.new(@user, @settings)
      end

      def keywords_section
        Presenters::Explore::Modules::ExploreKeywordsSection.new
      end

      def vocabularies_section
        Presenters::Explore::Modules::ExploreVocabulariesSection.new(@user, @settings)
      end

      def show_login
        @show_login && !@user
      end
    end
  end
end
