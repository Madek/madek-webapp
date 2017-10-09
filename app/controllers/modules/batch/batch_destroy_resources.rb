module Modules
  module Batch
    module BatchDestroyResources
      extend ActiveSupport::Concern

      include Modules::Batch::BatchAuthorization
      include Modules::Batch::BatchShared

      def batch_destroy_resources
        batch_resources = authorize_and_read_batch_resources(
          params,
          nil,
          MediaResourcePolicy::DestroyableScope)

        destroy_transaction(
          batch_resources[:media_entries],
          batch_resources[:collections])

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
          collections.each do |collection|
            # TODO: Remove this when cascade delete works:
            collection.meta_data.each(&:destroy!)
            collection.destroy!
          end
        end
      end
    end
  end
end
