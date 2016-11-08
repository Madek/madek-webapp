module Modules
  module MediaEntries
    module PermissionsUpdate
      extend ActiveSupport::Concern

      included do

        self.const_set 'PUBLIC_PERMISSIONS_RESET',
                       get_metadata_and_previews: false,
                       get_full_size: false

        private

        # TODO: for permission names use already defined constant
        def perms
          %i(
            get_metadata_and_previews get_full_size edit_metadata edit_permissions
          )
        end

        def user_permissions_params
          associated_entity_permissions_helper(:user, *perms)
        end

        def group_permissions_params
          associated_entity_permissions_helper(:group, *perms.first(3))
        end

        def api_client_permissions_params
          associated_entity_permissions_helper(:api_client, *perms.first(2))
        end

        def public_permissions_params
          media_entry_params
            .require(:public_permission)
            .permit(:get_metadata_and_previews, :get_full_size)
        end
      end
    end
  end
end
