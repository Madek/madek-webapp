module Presenters
  module Keywords
    class KeywordIndexForExplore < KeywordIndexWithUsageCount

      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      def image_url
        prepend_url_context preview_for_keyword_path(@app_resource, :medium)
      end

    end
  end
end
