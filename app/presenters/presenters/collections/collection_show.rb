module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResource::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource,
                     user,
                     user_scopes,
                     list_conf: nil)
        super(app_resource, user)
        @user_scopes = user_scopes
        @list_conf = list_conf
        @relations = \
          Presenters::Collections::CollectionRelations.new(
            @app_resource,
            @user,
            @user_scopes,
            list_conf: @list_conf)
      end

      def highlighted_media_resources
        Presenters::Collections::ChildMediaResources.new \
          @user_scopes[:highlighted_media_entries],
          @user,
          list_conf: @list_conf
      end
    end
  end
end
