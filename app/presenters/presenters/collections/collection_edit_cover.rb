module Presenters
  module Collections
    class CollectionEditCover < Presenters::Collections::CollectionShow

      include Presenters::Collections::Modules::CollectionResourceSelection

      def initialize(user, collection, user_scopes, list_params)
        super(collection, user, user_scopes, list_conf: list_params)

        child_presenters = scoped_child_resources
          .custom_order_by('created_at DESC')
          .map do |child|
          index_presenter('MediaEntry').new(child, @user)
        end

        @child_presenters = {
          resources: child_presenters
        }
      end

      def i18n
        super().merge(title: I18n.t(:collection_edit_cover_title))
      end

      def submit_url
        update_cover_collection_path(@app_resource)
      end

      def uuid_to_checked_hash
        cover_id = @app_resource.cover ? @app_resource.cover.id : nil
        Hash[
          @app_resource.child_media_resources.map do |resource|
            [resource.id, resource.id == cover_id]
          end
        ]
      end

      def cancel_url
        collection_path(@app_resource)
      end

      private

      def scoped_child_resources
        auth_policy_scope(@user, @app_resource.media_entries)
      end

      def index_presenter(type)
        name = 'Presenters::' + type.pluralize + '::' + type + 'Index'
        name.constantize
      end
    end
  end
end
