module Permissions
  class MediaEntryUserPermission < ActiveRecord::Base
    include ::Permissions::Modules::MediaEntry
    belongs_to :user

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         get_full_size: false, edit_metadata: false,
         edit_permissions: false }]) do
           joins(:media_entry).where("media_entries.responsible_user_id \
                 = media_entry_user_permissions.user_id").delete_all
         end
  end
end
