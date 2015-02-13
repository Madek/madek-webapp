module Presenters
  module FilterSets
    class FilterSetThumb < Presenters::Shared::Resources::ResourcesThumb

      def url
        filter_set_path @resource
      end

      def image_url(_size = :small)
        ActionController::Base.helpers.image_path \
          ::UI_GENERIC_THUMBNAIL[:filter_set]
        # TODO: implement
        #   - get a list of all entries matching the filter
        #   - select the first one that has an image, use that image
      end
    end
  end
end
