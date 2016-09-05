module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResource::MediaResourceRelations

      def child_media_resources
        # NOTE: filtering is not implemented (needs spec)
        Presenters::Collections::ChildMediaResources.new(
          @user_scopes[:child_media_resources],
          @user,
          can_filter: false,
          list_conf: @list_conf,
          load_meta_data: true)
      end

      def child_collections
        Presenters::Collections::ChildMediaResources.new(
          @user_scopes[:child_collections],
          @user,
          can_filter: false,
          list_conf: @list_conf,
          load_meta_data: true)
      end

    end
  end
end
