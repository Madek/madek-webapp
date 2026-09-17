require 'spec_helper'
require 'controllers/shared/media_resources/permissions/user_permissions_with_delegation'

describe MediaEntriesController do
  before :example do
    @user = create(:user)
  end

  context 'it authorizes' do
    before :example do
      @media_entry = create(:media_entry, responsible_user: create(:user))
    end

    it 'for edit' do
      expect do
        get :permissions_edit,
            params: { id: @media_entry.id },
            session: { user_id: @user.id }
      end.to raise_error(Errors::ForbiddenError)
    end

    it 'for update' do
      expect do
        put :permissions_update,
            params: {
              id: @media_entry.id,
              user_permissions: [{ user_id: create(:user).id,
                                   get_metadata_and_previews: true }] },
            session: { user_id: @user.id }
      end.to raise_error(Errors::ForbiddenError)
    end
  end

  it 'updates successfully' do
    media_entry = FactoryBot.create(:media_entry,
                                     responsible_user: @user)
    media_entry.user_permissions << \
      (up1 = FactoryBot.create(:media_entry_user_permission,
                                user: create(:user)))
    media_entry.user_permissions << \
      (up2 = FactoryBot.create(:media_entry_user_permission,
                                user: create(:user)))
    media_entry.group_permissions << \
      (gp1 = FactoryBot.create(:media_entry_group_permission,
                                group: create(:group)))
    media_entry.group_permissions << \
      (gp2 = FactoryBot.create(:media_entry_group_permission,
                                group: create(:group)))
    media_entry.api_client_permissions << \
      (apc1 = FactoryBot.create(:media_entry_api_client_permission,
                                 api_client: create(:api_client)))
    media_entry.api_client_permissions << \
      (apc2 = FactoryBot.create(:media_entry_api_client_permission,
                                 api_client: create(:api_client)))

    update_params = \
      { id: media_entry.id,
        media_entry:
          { user_permissions:
              [{ subject: { uuid: up1.user_id },
                 get_metadata_and_previews: \
                    (not up1.get_metadata_and_previews) },
               { subject: { uuid: up2.user_id } },
               { subject: { uuid: (user = create(:user)).id },
                 get_metadata_and_previews: true }],
            group_permissions:
              [{ subject: { uuid: gp1.group_id },
                 get_metadata_and_previews: \
                    (not gp1.get_metadata_and_previews) },
               { subject: { uuid: gp2.group_id } },
               { subject: { uuid: (group = create(:group)).id },
                 get_metadata_and_previews: true }],
            api_client_permissions:
              [{ subject: { uuid: apc1.api_client_id },
                 get_metadata_and_previews: \
                    (not apc1.get_metadata_and_previews) },
               { subject: { uuid: apc2.api_client_id } },
               { subject: { uuid: (api_client = create(:api_client)).id },
                 get_metadata_and_previews: true }],
            public_permission: {
              get_metadata_and_previews: \
                (not media_entry.get_metadata_and_previews),
              get_full_size: (not media_entry.get_full_size)
            }
          }
      }

    put :permissions_update,
        params: update_params,
        session: { user_id: @user.id }

    # check that old permissions were deleted
    [up1, up2, gp1, gp2, apc1, apc2].each do |p|
      expect { p.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    # check that the new one were created and have correct values
    expect(
      media_entry.user_permissions.find_by(user_id: up1.user_id)
        .get_metadata_and_previews
    ).to be (not up1.get_metadata_and_previews)
    expect(
      media_entry.user_permissions.find_by(user_id: user.id)
        .get_metadata_and_previews
    ).to be true
    expect(
      media_entry.group_permissions.find_by(group_id: gp1.group_id)
        .get_metadata_and_previews
    ).to be (not gp1.get_metadata_and_previews)
    expect(
      media_entry.group_permissions.find_by(group_id: group.id)
        .get_metadata_and_previews
    ).to be true
    expect(
      media_entry.api_client_permissions.find_by(api_client_id: apc1.api_client_id)
        .get_metadata_and_previews
    ).to be (not apc1.get_metadata_and_previews)
    expect(
      media_entry.api_client_permissions.find_by(api_client_id: api_client.id)
        .get_metadata_and_previews
    ).to be true

    # check the correct amount of permissions
    expect(media_entry.user_permissions.count).to be == 2
    expect(media_entry.group_permissions.count).to be == 2
    expect(media_entry.api_client_permissions.count).to be == 2

    # check public permissions
    old = media_entry.clone
    media_entry.reload
    expect(media_entry.get_metadata_and_previews)
      .to be (not old.get_metadata_and_previews)
    expect(media_entry.get_full_size).to be (not old.get_full_size)
  end

  it 'deletes permissions if no new provided for subject' do
    media_entry = FactoryBot.create(:media_entry,
                                     responsible_user: @user)
    media_entry.user_permissions << \
      FactoryBot.create(:media_entry_user_permission,
                         user: create(:user))
    media_entry.group_permissions << \
      FactoryBot.create(:media_entry_group_permission,
                         group: create(:group))
    media_entry.api_client_permissions << \
      FactoryBot.create(:media_entry_api_client_permission,
                         api_client: create(:api_client))

    update_params = \
      { id: media_entry.id,
        media_entry: {
          public_permission: {
            get_metadata_and_previews: true,
            get_full_size: true } } }

    put :permissions_update, params: update_params, session: { user_id: @user.id }

    media_entry.reload
    expect(media_entry.user_permissions.count).to be == 0
    expect(media_entry.group_permissions.count).to be == 0
    expect(media_entry.api_client_permissions.count).to be == 0
  end

  pending 'deletes permissions if only false for subject' do
    media_entry = FactoryBot.create(:media_entry,
                                     responsible_user: @user)
    media_entry.user_permissions << \
      up = FactoryBot.create(:media_entry_user_permission,
                              user: create(:user))
    media_entry.group_permissions << \
      FactoryBot.create(:media_entry_group_permission,
                         group: create(:group))
    media_entry.api_client_permissions << \
      FactoryBot.create(:media_entry_api_client_permission,
                         api_client: create(:api_client))

    update_params = \
      { id: media_entry.id,
        media_entry: {
          user_permissions: [{
            subject: { uuid: up.user.id },
            get_metadata_and_previews: false,
            get_full_size: false
          }],
          public_permission: {
            get_metadata_and_previews: true,
            get_full_size: true } } }

    put :permissions_update, params: update_params, session: { user_id: @user.id }

    media_entry.reload
    expect(media_entry.user_permissions.count).to be == 0
    expect(media_entry.group_permissions.count).to be == 0
    expect(media_entry.api_client_permissions.count).to be == 0
  end

  it 'creates log entry in edit_sessions' do
    media_entry = FactoryBot.create(:media_entry,
                                     get_metadata_and_previews: false,
                                     responsible_user: @user)
    update_params = \
      { id: media_entry.id,
        media_entry: {
          public_permission: { get_metadata_and_previews: true }
        }
      }

    expect do
      put :permissions_update, params: update_params, session: { user_id: @user.id }
    end.to change { media_entry.reload.edit_sessions.count }.by 1
  end

  context 'tracking creator and updator across different users' do
    before :example do
      # the acting/editing user (authorized via responsible_user)
      @editor = @user
      # a different user who originally created the existing permissions
      @original_creator = create(:user)
      @media_entry = create(:media_entry, responsible_user: @editor)
    end

    def put_update(permissions)
      put :permissions_update,
          params: {
            id: @media_entry.id,
            media_entry: permissions.merge(
              public_permission: { get_metadata_and_previews: false,
                                   get_full_size: false })
          },
          session: { user_id: @editor.id }
    end

    it 'preserves the original creator and stamps updator '\
       'when an existing user permission is changed' do
      receiver = create(:user)
      create(:media_entry_user_permission,
             media_entry: @media_entry,
             user: receiver,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: false)

      put_update(user_permissions: [{ subject: { uuid: receiver.id },
                                      get_metadata_and_previews: true }])

      perm = @media_entry.reload.user_permissions.find_by(user_id: receiver.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @editor.id
    end

    it 'sets the acting user as creator (and leaves updator empty) '\
       'for a newly added user permission' do
      receiver = create(:user)

      put_update(user_permissions: [{ subject: { uuid: receiver.id },
                                      get_metadata_and_previews: true }])

      perm = @media_entry.reload.user_permissions.find_by(user_id: receiver.id)
      expect(perm.creator_id).to eq @editor.id
      expect(perm.updator_id).to be_nil
    end

    it 'does not touch creator or updator when an existing user permission '\
       'is submitted unchanged' do
      receiver = create(:user)
      create(:media_entry_user_permission,
             media_entry: @media_entry,
             user: receiver,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: true,
             get_full_size: false,
             edit_metadata: false,
             edit_permissions: false)

      put_update(user_permissions: [{ subject: { uuid: receiver.id },
                                      get_metadata_and_previews: true,
                                      get_full_size: false,
                                      edit_metadata: false,
                                      edit_permissions: false }])

      perm = @media_entry.reload.user_permissions.find_by(user_id: receiver.id)
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @original_creator.id
    end

    it 'preserves the original creator and stamps updator '\
       'for a changed group permission' do
      group = create(:group)
      create(:media_entry_group_permission,
             media_entry: @media_entry,
             group: group,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: false)

      put_update(group_permissions: [{ subject: { uuid: group.id },
                                       get_metadata_and_previews: true }])

      perm = @media_entry.reload.group_permissions.find_by(group_id: group.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @editor.id
    end

    it 'preserves the original creator and stamps updator '\
       'for a changed api_client permission' do
      api_client = create(:api_client)
      create(:media_entry_api_client_permission,
             media_entry: @media_entry,
             api_client: api_client,
             creator: @original_creator,
             updator: @original_creator,
             get_metadata_and_previews: false)

      put_update(api_client_permissions: [{ subject: { uuid: api_client.id },
                                            get_metadata_and_previews: true }])

      perm = @media_entry.reload.api_client_permissions
        .find_by(api_client_id: api_client.id)
      expect(perm.get_metadata_and_previews).to be true
      expect(perm.creator_id).to eq @original_creator.id
      expect(perm.updator_id).to eq @editor.id
    end

    # Regression: previously `get_creator` collapsed all existing permissions to
    # a single creator and raised "Ambiguous creator for permissions." as soon as
    # two rows had different creators. Each permission must keep its own creator.
    it 'does not raise when existing user permissions have different creators '\
       'and preserves each individual creator' do
      creator_a = create(:user)
      creator_b = create(:user)
      receiver_a = create(:user)
      receiver_b = create(:user)
      create(:media_entry_user_permission,
             media_entry: @media_entry, user: receiver_a, creator: creator_a)
      create(:media_entry_user_permission,
             media_entry: @media_entry, user: receiver_b, creator: creator_b)

      expect do
        put_update(user_permissions: [
                     { subject: { uuid: receiver_a.id },
                       get_metadata_and_previews: true },
                     { subject: { uuid: receiver_b.id },
                       get_metadata_and_previews: true }
                   ])
      end.not_to raise_error

      @media_entry.reload
      perm_a = @media_entry.user_permissions.find_by(user_id: receiver_a.id)
      perm_b = @media_entry.user_permissions.find_by(user_id: receiver_b.id)
      expect(perm_a.creator_id).to eq creator_a.id
      expect(perm_b.creator_id).to eq creator_b.id
      expect(perm_a.updator_id).to eq @editor.id
      expect(perm_b.updator_id).to eq @editor.id
    end
  end

  include_examples 'user permissions with delegation', 'media_entry'
end
