module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResource::MediaResourceRelations

      def child_collections
        Presenters::Shared::MediaResource::MediaResources.new(
          @user_scopes[:child_collections],
          @user,
          can_filter: true,
          list_conf: @list_conf,
          load_meta_data: @load_meta_data)
      end
    end
  end
end
