module Modules
  module Batch
    module BatchRemoveFromSet
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchShared

      def batch_ask_remove_from_set
        presenter_values = presenter_values(params)

        parent_collection_id = params.require(:parent_collection_id)
        presenter_values[:parent_collection_id] = parent_collection_id

        @get = Presenters::Batch::BatchRemoveFromSet.new(presenter_values)
        respond_with(@get, template: 'batch/batch_ask_remove_from_set')
      end

      def batch_remove_from_set
        return_to = params.require(:return_to)

        action_values = action_values(
          params,
          params.require(:parent_collection_id))

        ActiveRecord::Base.transaction do
          remove_transaction(
            action_values[:parent_collection],
            action_values[:media_entries],
            action_values[:collections])
        end

        redirect_to(return_to)
      end
    end
  end
end
