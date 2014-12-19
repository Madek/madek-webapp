module Permissions

  class MediaEntryUserPermission < ActiveRecord::Base

    belongs_to :media_entry
    belongs_to :user
    belongs_to :updator, class_name: 'User'

    def self.destroy_ineffective
      MediaEntryUserPermission.where(get_metadata_and_previews: false,
                                     get_full_size: false,
                                     edit_metadata: false,
                                     edit_permissions: false).delete_all
      MediaEntryUserPermission.joins(:media_entry)
        .where(%(media_entries.responsible_user_id \
                 = media_entry_user_permissions.user_id)) \
        .delete_all
    end

  end

end
