module Presenters
  module FilterSets
    class FilterSetIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::FilterSets::Modules::FilterSetCommon

      def url
        prepend_url_context filter_set_path @app_resource
      end

      def image_url
        ActionController::Base.helpers.image_path \
          Madek::Constants::Webapp::UI_GENERIC_THUMBNAIL[:filter_set]
        # TODO: implement
        #   - get a list of all entries matching the filter
        #   - select the first one that has an image, use that image
      end

    end
  end
end
