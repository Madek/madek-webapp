module Modules
  module Batch
    module BatchAuthorization
      extend ActiveSupport::Concern

      def authorize_media_entries_for_view!(user, media_entries)
        authorized_media_entries = \
          MediaEntryPolicy::Scope.new(user, media_entries).resolve
        if media_entries.count != authorized_media_entries.count
          raise Errors::ForbiddenError, 'Not allowed to view all resources!'
        end
      end

      def authorize_collections_for_view!(user, collections)
        authorized_collections = \
          CollectionPolicy::Scope.new(user, collections).resolve
        if collections.count != authorized_collections.count
          raise Errors::ForbiddenError, 'Not allowed to view all resources!'
        end
      end

      def authorize_media_entries_for_batch_edit!(user, media_entries)
        authorized_media_entries = \
          MediaEntryPolicy::EditableScope.new(user, media_entries).resolve
        if media_entries.count != authorized_media_entries.count
          raise Errors::ForbiddenError, 'Not allowed to edit all resources!'
        end
      end

    end
  end
end
