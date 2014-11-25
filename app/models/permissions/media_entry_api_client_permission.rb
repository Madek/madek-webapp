module Permissions

  class MediaEntryApiClientPermission < ActiveRecord::Base

    belongs_to :media_entry
    belongs_to :api_client
    belongs_to :updator, class_name: "User"

    def self.destroy_ineffective
      MediaEntryApiClientPermission \
        .where(get_metadata_and_previews: false, 
               get_full_size: false).delete_all
    end

  end

end
