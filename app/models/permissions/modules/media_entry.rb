module Permissions
  module Modules
    module MediaEntry
      extend ActiveSupport::Concern
      include ::Permissions::Modules::DefineDestroyIneffective

      included do
        belongs_to :updator, class_name: 'User'
        belongs_to :media_entry
      end

      PERMISSION_TYPES = \
        [:get_metadata_and_previews,
         :get_full_size,
         :edit_metadata,
         :edit_permissions]
    end
  end
end
