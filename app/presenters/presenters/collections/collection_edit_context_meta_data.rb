module Presenters
  module Collections
    class CollectionEditContextMetaData \
      < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::Collections::Modules::CollectionCommon

      attr_reader :context_id

      def initialize(app_resource, user, context_id)
        @app_resource = app_resource
        @user = user
        @recursed_collections_for_cover = []
        @_unused_list_conf = {}
        @context_id = context_id
      end

    end
  end
end
