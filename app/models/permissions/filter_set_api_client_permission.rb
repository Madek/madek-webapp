module Permissions

  class FilterSetApiClientPermission < ActiveRecord::Base

    belongs_to :filter_set
    belongs_to :api_client
    belongs_to :updator, class_name: "User"

    def self.destroy_ineffective
      FilterSetApiClientPermission.where(get_metadata_and_previews: false, edit_metadata_and_filter: false).delete_all
    end

  end

end
