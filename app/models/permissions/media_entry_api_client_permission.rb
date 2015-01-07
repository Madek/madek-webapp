module Permissions
  class MediaEntryApiClientPermission < ActiveRecord::Base
    include ::Permissions::Modules::MediaEntry
    belongs_to :api_client
    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         get_full_size: false }])
  end
end
