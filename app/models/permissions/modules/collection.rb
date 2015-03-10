module Permissions
  module Modules
    module Collection
      extend ActiveSupport::Concern
      include ::Permissions::Modules::DefineDestroyIneffective
      included do
        belongs_to :collection
        belongs_to :updator, class_name: 'User'
        define_destroy_ineffective [{ get_metadata_and_previews: false,
                                      edit_metadata_and_relations: false }]
      end

      PERMISSION_TYPES = \
        [:get_metadata_and_previews,
         :edit_metadata_and_relations,
         :edit_permissions]
    end
  end
end
