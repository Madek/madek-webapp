require 'spec_helper'

require_relative '../../features/shared/batch_permissions_helper'
include BatchPermissionsHelper

describe BatchController do
  context 'Action: Batch MediaEntry Permissions' do

    it 'updates properly' do

      ################################ DATA #######################################
      setup_batch_permissions_test_data(MediaEntry) # from BatchPermissionsHelper

      ################################ REQUEST ####################################
      update_data = \
        {
          resource_ids: [@resource_1, @resource_2],
          permissions: {
            user_permissions: [
              { subject: @case_1_user.id },
              { subject: @case_1_delegation.id, get_metadata_and_previews: true },
              { subject: @case_3_user.id },
              { subject: @case_4_user.id, edit_permissions: true },
              { subject: @case_6_user.id, get_metadata_and_previews: false },
              { subject: @case_7_user.id, get_metadata_and_previews: true },
              { subject: @case_8_user.id },
              { subject: @case_10_user.id,
                get_metadata_and_previews: true,
                get_full_size: true,
                edit_metadata: true,
                edit_permissions: true },
              { subject: @case_10_delegation.id,
                get_metadata_and_previews: true,
                get_full_size: false,
                edit_metadata: false,
                edit_permissions: false }
            ],
            group_permissions: [
              { subject: @case_2_group.id },
              { subject: @case_5_group.id, get_metadata_and_previews: false },
              { subject: @case_9_group.id, get_metadata_and_previews: false },
              { subject: @case_10_group.id,
                get_metadata_and_previews: true,
                get_full_size: false,
                edit_metadata: false }
            ],
            api_client_permissions: [
              { subject: @case_2_api_client.id },
              { subject: @case_5_api_client.id, get_metadata_and_previews: false },
              { subject: @case_9_api_client.id, get_metadata_and_previews: false },
              { subject: @case_10_api_client.id,
                get_metadata_and_previews: true,
                get_full_size: false }
            ],
            public_permission: {
              get_metadata_and_previews: true
            }
          }
        }

      return_to_url = '/my'

      put :batch_update_entry_permissions,
          params: update_data.merge(format: :json, return_to: return_to_url),
          session: { user_id: @logged_in_user.id }

      ################################ ASSERTIONS #################################

      expect(response.status).to be == 200
      expect(JSON.parse(response.body)['forward_url']).to be == return_to_url

      check_batch_permissions_results(MediaEntry) # from BatchPermissionsHelper
    end

    it 'logs into edit_sessions for all entries' do
      ################################ DATA #######################################
      setup_batch_permissions_test_data(MediaEntry) # from BatchPermissionsHelper
      #############################################################################

      update_data = \
        {
          resource_ids: [@resource_1.id, @resource_2.id],
          permissions: {
            public_permission: {
              get_metadata_and_previews: true
            }
          }
        }

      entry_1_before_count = @resource_1.edit_sessions.count
      entry_2_before_count = @resource_2.edit_sessions.count

      put :batch_update_entry_permissions,
          params: update_data.merge(format: :json, return_to: '/my'),
          session: { user_id: @logged_in_user.id }

      expect(response.status).to be == 200

      entry_1_after_count = @resource_1.reload.edit_sessions.count
      entry_2_after_count = @resource_2.reload.edit_sessions.count

      expect(entry_1_after_count - entry_1_before_count).to be == 1
      expect(entry_2_after_count - entry_2_before_count).to be == 1
    end
  end

  context 'tracking creator and updator across different users' do
    before :example do
      @editor = create(:user)
      @original_creator = create(:user)
      @media_entry = create(:media_entry, responsible_user: @editor)
    end

    def batch_put(user_permissions)
      put :batch_update_entry_permissions,
          params: {
            resource_ids: [@media_entry.id],
            permissions: {
              user_permissions: user_permissions,
              public_permission: { get_metadata_and_previews: false }
            },
            format: :json,
            return_to: '/my'
          },
          session: { user_id: @editor.id }
    end

    it 'preserves the original creator and stamps updator '\
       'for an existing permission' do
      receiver = create(:user)
      create(:media_entry_user_permission,
             media_entry: @media_entry,
             user: receiver,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: false)

      batch_put([{ subject: receiver.id, get_metadata_and_previews: true }])

      expect(response.status).to be == 200
      perm = @media_entry.reload.user_permissions.find_by(user_id: receiver.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @editor.id
    end

    it 'sets the acting user as creator for a newly added permission' do
      receiver = create(:user)

      batch_put([{ subject: receiver.id, get_metadata_and_previews: true }])

      expect(response.status).to be == 200
      perm = @media_entry.reload.user_permissions.find_by(user_id: receiver.id)
      expect(perm.creator_id).to eq @editor.id
    end

    it 'does not stamp updator when an existing permission is unchanged' do
      receiver = create(:user)
      create(:media_entry_user_permission,
             media_entry: @media_entry,
             user: receiver,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: true)

      batch_put([{ subject: receiver.id, get_metadata_and_previews: true }])

      expect(response.status).to be == 200
      perm = @media_entry.reload.user_permissions.find_by(user_id: receiver.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @original_creator.id
    end
  end

  context 'Action: Batch Collection Permissions' do

    it 'updates properly' do

      ################################ DATA #######################################
      setup_batch_permissions_test_data(Collection) # from BatchPermissionsHelper

      ################################ REQUEST ####################################
      update_data = \
        {
          resource_ids: [@resource_1, @resource_2],
          permissions: {
            user_permissions: [
              { subject: @case_1_user.id },
              { subject: @case_1_delegation.id, get_metadata_and_previews: true },
              { subject: @case_3_user.id },
              { subject: @case_4_user.id, edit_permissions: true },
              { subject: @case_6_user.id, get_metadata_and_previews: false },
              { subject: @case_7_user.id, get_metadata_and_previews: true },
              { subject: @case_8_user.id },
              { subject: @case_10_user.id,
                get_metadata_and_previews: true,
                edit_metadata_and_relations: true,
                edit_permissions: true },
              { subject: @case_10_delegation.id,
                get_metadata_and_previews: true,
                edit_metadata_and_relations: false,
                edit_permissions: false }
            ],
            group_permissions: [
              { subject: @case_2_group.id },
              { subject: @case_5_group.id, get_metadata_and_previews: false },
              { subject: @case_9_group.id, get_metadata_and_previews: false },
              { subject: @case_10_group.id,
                get_metadata_and_previews: true,
                edit_metadata_and_relations: false }
            ],
            api_client_permissions: [
              { subject: @case_2_api_client.id },
              { subject: @case_5_api_client.id, get_metadata_and_previews: false },
              { subject: @case_9_api_client.id, get_metadata_and_previews: false },
              { subject: @case_10_api_client.id,
                get_metadata_and_previews: true }
            ],
            public_permission: {
              get_metadata_and_previews: true
            }
          }
        }

      return_to_url = '/my'

      put :batch_update_collection_permissions,
          params: update_data.merge(format: :json, return_to: return_to_url),
          session: { user_id: @logged_in_user.id }

      ################################ ASSERTIONS #################################

      expect(response.status).to be == 200
      expect(JSON.parse(response.body)['forward_url']).to be == return_to_url

      check_batch_permissions_results(Collection) # from BatchPermissionsHelper
    end

  end
end
