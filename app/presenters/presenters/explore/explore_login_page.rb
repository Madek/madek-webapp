module Presenters
  module Explore
    class ExploreLoginPage < Presenter

      def initialize(user, settings)
        @user = user
        @settings = settings
      end

      def teaser_entries
        Presenters::MediaEntries::MediaEntries.new \
          Collection.find(@settings.teaser_set_id).media_entries,
          @user,
          list_conf: {}
      end

    end
  end
end
