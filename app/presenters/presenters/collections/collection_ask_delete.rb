module Presenters
  module Collections
    class CollectionAskDelete < Presenters::Collections::CollectionShow

      def initialize(user, collection, user_scopes, list_params)
        super(collection, user, user_scopes, list_conf: list_params)
      end

      def submit_url
        collection_path(@app_resource)
      end

      def cancel_url
        collection_path(@app_resource)
      end
    end
  end
end
