require 'spec_helper'

describe MediaEntriesController do
  context 'tracking creator and updator on transfer of responsibility' do
    before :example do
      # the acting user is the (current) responsible user performing the transfer
      @editor = create(:user)
      # a different user who originally created the retained permission
      @original_creator = create(:user)
      # the entity responsibility is transferred to
      @new_user = create(:user)
      @media_entry = create(:media_entry, responsible_user: @editor)
    end

    def transfer_to(new_entity, permissions)
      put :update_transfer_responsibility,
          params: {
            id: @media_entry.id,
            transfer_responsibility: {
              entity: new_entity.id,
              type: new_entity.class.name,
              permissions: permissions
            }
          },
          format: :json,
          session: { user_id: @editor.id }
    end

    it 'sets the acting user as creator (and leaves updator empty) '\
       'for the newly created retained permission' do
      transfer_to(@new_user, view: true, download: true)

      expect(response.status).to be == 200
      perm = @media_entry.reload.user_permissions.find_by(user_id: @editor.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @editor.id
      expect(perm.updator_id).to be_nil
    end

    it 'preserves the original creator and stamps updator '\
       'when the retained permission already exists and changes' do
      create(:media_entry_user_permission,
             media_entry: @media_entry,
             user: @editor,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: false,
             get_full_size: true,
             edit_metadata: false,
             edit_permissions: false)

      transfer_to(@new_user, view: true, download: true)

      expect(response.status).to be == 200
      perm = @media_entry.reload.user_permissions.find_by(user_id: @editor.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @editor.id
    end

    it 'does not touch creator or updator '\
       'when the retained permission already exists unchanged' do
      create(:media_entry_user_permission,
             media_entry: @media_entry,
             user: @editor,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: true,
             get_full_size: false,
             edit_metadata: false,
             edit_permissions: false)

      transfer_to(@new_user, view: true)

      expect(response.status).to be == 200
      perm = @media_entry.reload.user_permissions.find_by(user_id: @editor.id)
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @original_creator.id
    end
  end
end
