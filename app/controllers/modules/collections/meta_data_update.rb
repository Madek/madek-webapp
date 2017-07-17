module Modules
  module Collections
    module MetaDataUpdate
      extend ActiveSupport::Concern

      include Modules::Resources::MetaDataUpdate
      include Modules::Batch::BatchLogIntoEditSessions
      include Modules::SharedUpdate
      include Modules::SharedBatchUpdate

      def batch_edit_all
        auth_authorize :dashboard, :logged_in?

        collection_id = params.require(:id)
        type = params.require(:type)

        collection = Collection.unscoped.find(collection_id)

        scope = batch_scope_by_type(collection, type)
        authorize_resources_for_batch_edit!(scope)

        all_resources = scope
        authorized_resources = auth_policy_scope(
          current_user, all_resources, MediaResourcePolicy::EditableScope)

        shared_handle_batch_edit_response(
          type.camelize.constantize,
          all_resources,
          authorized_resources,
          collection,
          params[:context_id],
          params[:by_vocabulary]
        )
      end

      def batch_update_all
        shared_batch_meta_data_update(params[:type].camelize.constantize)
      end

      def batch_edit_meta_data_by_context
        shared_batch_edit_meta_data_by_context(Collection)
      end

      def batch_edit_meta_data_by_vocabularies
        shared_batch_edit_meta_data_by_vocabularies(Collection)
      end

      def batch_meta_data_update
        shared_batch_meta_data_update(Collection)
      end

      private

      def return_to_param
        params.require(:return_to)
      end

      def batch_scope_by_type(collection, type)
        children =
          case type
          when 'media_entry' then collection.media_entries
          when 'collection' then collection.collections
          else
            throw 'Unexpected type: ' + type
          end
        auth_policy_scope(
          current_user, children, MediaResourcePolicy::ViewableScope)
      end
    end
  end
end
