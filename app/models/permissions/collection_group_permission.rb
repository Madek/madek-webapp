module Permissions
  class CollectionGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::Collection
    belongs_to :group
    define_destroy_ineffective [{ get_metadata_and_previews: false,
                                  edit_metadata_and_relations: false }]
  end
end
