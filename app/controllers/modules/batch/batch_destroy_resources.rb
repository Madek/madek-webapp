module Modules
  module Batch
    module BatchDestroyResources
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchShared

      def batch_destroy_resources
        action_values = action_values(
          params,
          nil)

        destroy_transaction(
          action_values[:media_entries],
          action_values[:collections])

        json_respond(I18n.t('batch_destroy_resources_success'), 'success')
      end

      private

      def json_respond(message, result)
        respond_to do |format|
          format.json do
            flash[:success] = message
            render(json: { result: result })
          end
        end
      end

      def destroy_transaction(media_entries, collections)
        ActiveRecord::Base.transaction do
          media_entries.each do |media_entry|
            # TODO: Remove this when cascade delete works:
            media_entry.meta_data.each(&:destroy!)
            media_entry.destroy!
          end
          collections.each do |collections|
            # TODO: Remove this when cascade delete works:
            collections.meta_data.each(&:destroy!)
            collections.destroy!
          end
        end
      end
    end
  end
end
