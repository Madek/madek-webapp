module Permissions
  class MediaEntryGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::MediaEntry
    belongs_to :group

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         get_full_size: false, edit_metadata: false }])
  end
end
