module Permissions

  class MediaEntryUserPermission < ActiveRecord::Base

    belongs_to :media_entry
    belongs_to :user
    belongs_to :updator, class_name: "User"

    def self.destroy_ineffective
      MediaEntryUserPermission.where(get_metadata_and_previews: false, get_full_size: false, edit_metadata: false, edit_permissions: false).delete_all
      MediaEntryUserPermission.connection.execute <<-SQL
        DELETE
          FROM "media_entry_user_permissions"
            USING "media_entries"
          WHERE "media_entries"."id" = "media_entry_user_permissions"."media_entry_id"
          AND media_entry_user_permissions.user_id = media_entries.responsible_user_id 
      SQL
    end

  end

end
