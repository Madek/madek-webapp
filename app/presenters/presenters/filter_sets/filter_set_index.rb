module Presenters
  module FilterSets
    class FilterSetIndex < Presenters::Shared::MediaResource::MediaResourceIndex

      include Presenters::FilterSets::Modules::FilterSetCommon

      def initialize(app_resource, user, list_conf: nil, show_relations: false)
        super(app_resource, user, list_conf: list_conf)
        @show_relations = show_relations
      end

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

      # --- TODO: relations
      def parent_collections
        nil
      end

      def sibling_collections
        nil
      end
      # --- TODO: relations

      def parent_relation_resources
        nil
      end

      def child_relation_resources
        nil
      end

    end
  end
end
