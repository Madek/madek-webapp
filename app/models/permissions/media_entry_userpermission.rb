module Permissions

  class MediaEntryUserpermission < ActiveRecord::Base

    belongs_to :media_entry
    belongs_to :user
    belongs_to :updator, class_name: "User"

    def self.destroy_ineffective
      MediaEntryUserpermission.where(view: false, edit:false, download: false,manage: false).delete_all
      MediaEntryUserpermission.connection.execute <<-SQL
        DELETE
          FROM "media_entry_userpermissions"
            USING "media_entries"
          WHERE "media_entries"."id" = "media_entry_userpermissions"."media_entry_id"
          AND media_entry_userpermissions.user_id = media_entries.responsible_user_id 
      SQL
    end

  end

end
