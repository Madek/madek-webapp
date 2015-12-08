module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResource::MediaResourceRelations

      def child_media_resources
        Presenters::Collections::ChildMediaResources.new(
          @user_scopes[:child_media_resources],
          @user,
          list_conf: @list_conf)
      end
    end
  end
end
