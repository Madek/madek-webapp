module Modules
  module Collections
    module MetaDataUpdate
      extend ActiveSupport::Concern

      include Modules::Resources::MetaDataUpdate
      include Modules::Batch::BatchLogIntoEditSessions
      include Modules::SharedUpdate
      include Modules::SharedBatchUpdate

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
