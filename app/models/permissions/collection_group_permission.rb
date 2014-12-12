module Permissions

  class CollectionGroupPermission < ActiveRecord::Base

    belongs_to :collection
    belongs_to :group
    belongs_to :updator, class_name: 'User'

    def self.destroy_ineffective
      CollectionGroupPermission.where(get_metadata_and_previews: false, edit_metadata_and_relations: false).delete_all
    end

  end

end
