require 'spec_helper'

require_relative '../../features/shared/batch_permissions_helper'
include BatchPermissionsHelper

describe BatchController do
  context 'Action: Batch MediaEntry Permissions' do

    it 'updates properly' do

      ################################ DATA #######################################
      setup_batch_permissions_test_data # from BatchPermissionsHelper

      ################################ REQUEST ####################################
      update_data = \
        {
          resource_ids: [@entry_1, @entry_2],
          permissions: {
            user_permissions: [
              { subject: @case_1_user.id },
              { subject: @case_3_user.id },
              { subject: @case_4_user.id, edit_permissions: true },
              { subject: @case_6_user.id, get_metadata_and_previews: false },
              { subject: @case_7_user.id, get_metadata_and_previews: true },
              { subject: @case_8_user.id },
              { subject: @case_10_user.id,
                get_metadata_and_previews: true,
                get_full_size: true,
                edit_metadata: false,
                edit_permissions: false }
            ],
            group_permissions: [
              { subject: @case_2_group.id },
              { subject: @case_5_group.id, get_metadata_and_previews: false },
              { subject: @case_9_group.id, get_full_size: false },
              { subject: @case_10_group.id,
                get_metadata_and_previews: true,
                get_full_size: true,
                edit_metadata: false }
            ],
            api_client_permissions: [
              { subject: @case_2_api_client.id },
              { subject: @case_5_api_client.id, get_metadata_and_previews: false },
              { subject: @case_9_api_client.id, get_full_size: false },
              { subject: @case_10_api_client.id,
                get_metadata_and_previews: true,
                get_full_size: true }
            ],
            public_permission: {
              get_full_size: true
            }
          }
        }

      return_to_url = '/my'

      put :batch_update_entry_permissions,
          update_data.merge(format: :json, return_to: return_to_url),
          user_id: @logged_in_user.id

      ################################ ASSERTIONS #################################

      expect(response.status).to be == 200
      expect(JSON.parse(response.body)['forward_url']).to be == return_to_url

      check_batch_permissions_results # from BatchPermissionsHelper
    end
  end
end
