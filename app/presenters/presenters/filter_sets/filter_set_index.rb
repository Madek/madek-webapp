module Presenters
  module FilterSets
    class FilterSetIndex < Presenters::Shared::MediaResources::MediaResourceIndex

      include Presenters::FilterSets::Modules::FilterSetCommon

      def url
        filter_set_path @app_resource
      end

      def image_url(_size = :small)
        ActionController::Base.helpers.image_path \
          ::UI_GENERIC_THUMBNAIL[:filter_set]
        # TODO: implement
        #   - get a list of all entries matching the filter
        #   - select the first one that has an image, use that image
      end

      # TODO: relations
      def parent_collections
        nil
      end

      def sibling_collections
        nil
      end
    end
  end
end
