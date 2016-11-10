module Modules
  module Collections
    module MetaDataUpdate
      extend ActiveSupport::Concern

      include Modules::Resources::MetaDataUpdate
      include Modules::Batch::BatchLogIntoEditSessions
      include Modules::SharedUpdate
      include Modules::SharedBatchUpdate

      def batch_edit_context_meta_data
        shared_batch_edit_context_meta_data(Collection)
      end

      def batch_edit_meta_data
        shared_batch_edit_meta_data(Collection)
      end

      def batch_meta_data_update
        shared_batch_meta_data_update(Collection)
      end
    end
  end
end
