module Modules
  module MediaEntries
    module PermissionsUpdate
      extend ActiveSupport::Concern

      included do

        self.const_set 'PUBLIC_PERMISSIONS_RESET',
                       get_metadata_and_previews: false,
                       get_full_size: false

        private

        def user_permissions_params
          # TODO: for permission names use already defined constant
          associated_entity_permissions_helper(:user,
                                               :get_metadata_and_previews,
                                               :get_full_size,
                                               :edit_metadata,
                                               :edit_permissions)
        end

        def group_permissions_params
          # TODO: for permission names use already defined constant
          associated_entity_permissions_helper(:group,
                                               :get_metadata_and_previews,
                                               :get_full_size,
                                               :edit_metadata)
        end

        def api_client_permissions_params
          # TODO: for permission names use already defined constant
          associated_entity_permissions_helper(:api_client,
                                               :get_metadata_and_previews,
                                               :edit_metadata)
        end

        def public_permissions_params
          media_entry_params.permit(:get_metadata_and_previews, :get_full_size)
        end
      end
    end
  end
end
