module Presenters
  module Explore
    class PersonIndexForExplore < Presenters::People::PersonIndexWithUsageCount

      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      def image_url
        prepend_url_context catalog_key_item_thumb_path(:people,
                                                        @app_resource,
                                                        :medium)
      end
    end
  end
end
