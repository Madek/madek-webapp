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

        scope = \
          case type
          when 'media_entry' then collection.media_entries
          when 'collection' then collection.collections
          else
            throw 'Unexpected type: ' + type
          end

        authorize_resources_for_batch_edit!(scope)

        return_to_param = params.require(:return_to)

        @get = Presenters::MediaEntries::BatchEditContextMetaData.new(
          type.camelize.constantize,
          current_user,
          context_id: params[:context_id],
          by_vocabularies: params[:by_vocabulary],
          return_to: return_to_param,
          collection: collection)
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
    end
  end
end
