module Modules
  module Collections
    module PermissionsUpdate
      extend ActiveSupport::Concern

      included do

        self.const_set 'PUBLIC_PERMISSIONS_RESET',
                       get_metadata_and_previews: false

        private

        # TODO: for permission names use already defined constant
        def perms
          %i(
            get_metadata_and_previews edit_metadata_and_relations edit_permissions
          )
        end

        def user_permissions_params
          associated_entity_permissions_helper(:user, *perms)
        end

        def group_permissions_params
          associated_entity_permissions_helper(:group, *perms.first(2))
        end

        def api_client_permissions_params
          associated_entity_permissions_helper(:api_client, *perms.first(1))
        end

        def public_permissions_params
          collection_params
            .require(:public_permission)
            .permit(:get_metadata_and_previews)
        end
      end
    end
  end
end
