module Permissions

  class FilterSetGroupPermission < ActiveRecord::Base

    belongs_to :filter_set
    belongs_to :group
    belongs_to :updator, class_name: 'User'

    def self.destroy_ineffective
      FilterSetGroupPermission.where(get_metadata_and_previews: false, edit_metadata_and_filter: false).delete_all
    end

  end

end
