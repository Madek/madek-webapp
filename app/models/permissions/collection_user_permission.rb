module Permissions

  class CollectionUserPermission < ActiveRecord::Base

    belongs_to :collection
    belongs_to :user
    belongs_to :updator, class_name: 'User'

    def self.destroy_ineffective
      CollectionUserPermission.where(get_metadata_and_previews: false,
                                     edit_metadata_and_relations: false).delete_all
      CollectionUserPermission.joins(:collection).where(
        'collections.responsible_user_id = collection_user_permissions.user_id') \
        .delete_all
    end

  end

end
