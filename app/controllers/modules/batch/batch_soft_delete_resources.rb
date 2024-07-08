module Modules
  module Batch
    module BatchSoftDeleteResources
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
            media_entry.soft_delete
          end
          collections.each do |collection|
            collection.soft_delete
          end
        end
      end
    end
  end
end
