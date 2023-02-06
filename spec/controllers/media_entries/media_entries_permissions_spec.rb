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

  include_examples 'user permissions with delegation', 'media_entry'
end
