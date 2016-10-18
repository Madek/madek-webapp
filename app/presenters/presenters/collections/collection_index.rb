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

    end
  end
end
