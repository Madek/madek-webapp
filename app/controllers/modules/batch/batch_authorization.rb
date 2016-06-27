module Modules
  module Batch
    module BatchAuthorization
      extend ActiveSupport::Concern

      def authorize_media_entries_for_batch_edit!(user, media_entries)
        authorized_media_entries = \
          MediaEntryPolicy::BatchEditScope.new(user, media_entries).resolve
        if media_entries.count != authorized_media_entries.count
          raise Errors::ForbiddenError, 'Not allowed to edit all resources!'
        end
      end

    end
  end
end
