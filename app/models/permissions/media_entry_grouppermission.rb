module Permissions

  class MediaEntryGrouppermission < ActiveRecord::Base

    belongs_to :media_entry
    belongs_to :group
    belongs_to :updator, class_name: "User"

    def self.destroy_ineffective
      MediaEntryGrouppermission.where(get_metadata_and_previews: false, get_full_size: false, edit_metadata: false).delete_all
    end

  end

end
