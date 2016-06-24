module Presenters
  module Explore
    class ExploreLoginPage < Presenter

      def initialize(user, settings)
        @user = user
        @settings = settings
      end

      def teaser_entries
        teaser = Collection.find_by_id(@settings.teaser_set_id)
        return unless teaser
        Presenters::MediaEntries::MediaEntries.new(
          teaser.media_entries, @user, list_conf: {})
      end

    end
  end
end
