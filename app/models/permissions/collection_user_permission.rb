module Permissions
  class CollectionUserPermission < ActiveRecord::Base
    include ::Permissions::Modules::Collection
    belongs_to :user

    define_destroy_ineffective(
      [{ get_metadata_and_previews: false,
         edit_metadata_and_relations: false }]) do
        joins(:collection).where(
          "collections.responsible_user_id \
          = collection_user_permissions.user_id").delete_all
    end

  end

end
