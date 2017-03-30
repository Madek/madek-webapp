module Modules
  module Batch
    module BatchRemoveFromSet
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchShared

      def batch_ask_remove_from_set
        presenter_values = presenter_values(
          params, MediaResourcePolicy::ViewableScope)

        parent_collection_id = params.require(:parent_collection_id)
        presenter_values[:parent_collection_id] = parent_collection_id

        @get = Presenters::Batch::BatchRemoveFromSet.new(presenter_values)
        respond_with(@get, template: 'batch/batch_ask_remove_from_set')
      end

      def batch_remove_from_set
        return_to = params.require(:return_to)

        batch_resources = authorize_and_read_batch_resources(
          params,
          params.require(:parent_collection_id),
          MediaResourcePolicy::ViewableScope)

        ActiveRecord::Base.transaction do
          remove_transaction(
            batch_resources[:parent_collection],
            batch_resources[:media_entries],
            batch_resources[:collections])
        end

        redirect_to(return_to)
      end
    end
  end
end
