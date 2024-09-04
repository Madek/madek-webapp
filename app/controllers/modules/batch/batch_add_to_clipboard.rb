module Modules
  module Batch
    module BatchAddToClipboard
      extend ActiveSupport::Concern

      include Modules::Batch::BatchShared

      include Clipboard

      private

      def batch_add_resources_to_clipboard(user, parameters)
        auth_authorize User

        ActiveRecord::Base.transaction do
          do_batch_add_resources_to_clipboard(user, parameters)
        end

        json_respond(I18n.t('clipboard_batch_add_success'), 'success')
      end

      def batch_remove_resources_from_clipboard(user, parameters)
        auth_authorize User

        clipboard_deleted = false
        ActiveRecord::Base.transaction do
          clipboard_deleted = do_batch_remove_resources_from_clipboard(
            user, parameters)
        end

        json_respond(
          I18n.t('clipboard_batch_remove_success'),
          clipboard_deleted ? 'clipboard_deleted' : 'success')
      end

      def batch_remove_all_resources_from_clipboard(user)
        auth_authorize User

        ActiveRecord::Base.transaction do
          do_batch_remove_all_resources_to_clipboard(user)
        end

        json_respond(
          I18n.t('clipboard_batch_remove_success'),
          'success'
        )
      end

      def do_batch_remove_all_resources_to_clipboard(user)
        clipboard_collection = clipboard_collection(user)

        Arcs::CollectionMediaEntryArc.where(
          collection: clipboard_collection).delete_all
        Arcs::CollectionCollectionArc.where(
          parent: clipboard_collection).delete_all

        Collection.unscoped.delete(clipboard_collection.id)
      end

      def do_batch_add_resources_to_clipboard(user, parameters)
        ensure_clipboard_collection(user)
        batch_resources = authorize_and_read_batch_resources(
          parameters,
          clipboard_collection(user).id,
          MediaResourcePolicy::ViewableScope,
          skip_parent_authorization: true)

        add_transaction(
          batch_resources[:parent_collection],
          batch_resources[:media_entries],
          batch_resources[:collections])
      end

      def do_batch_remove_resources_from_clipboard(user, parameters)
        clipboard_deleted = false
        if clipboard_collection(user)

          clipboard = clipboard_collection(user)
          batch_resources = authorize_and_read_batch_resources(
            parameters,
            clipboard.id,
            MediaResourcePolicy::ViewableScope,
            skip_parent_authorization: true)

          remove_transaction(
            batch_resources[:parent_collection],
            batch_resources[:media_entries],
            batch_resources[:collections])

          clipboard.reload
          if (clipboard.media_entries.count == 0 &&
            clipboard.collections.count == 0)
            Collection.unscoped.delete(clipboard.id)
            clipboard_deleted = true
          end
        end
        clipboard_deleted
      end

      def json_respond(message, result)
        respond_to do |format|
          format.json do
            flash[:success] = message
            render(json: { result: result })
          end
        end
      end

      def ensure_clipboard_collection(user)
        unless clipboard_collection(user)
          Collection.create!(
            get_metadata_and_previews: false,
            responsible_user: user,
            creator: user,
            clipboard_user_id: user.id)
        end
      end
    end
  end
end
