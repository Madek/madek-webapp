module Presenters
  module Collections
    class CollectionIndex < Presenters::Shared::MediaResource::MediaResourceIndex
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(
          app_resource,
          user,
          list_conf: nil,
          async_cover: false,
          load_meta_data: false)
        super(app_resource, user)
        @list_conf = list_conf
        @async_cover = async_cover
        @load_meta_data = load_meta_data
      end

      def cover
        CollectionThumbUrl.new(@app_resource, @user).get_cover
      end

      def list_meta_data_url
        list_meta_data_collection_path(@app_resource)
      end

      def set_primary_custom_url
        set_primary_custom_url_collection_path(@app_resource.id, @app_resource.id)
      end

    end
  end
end
