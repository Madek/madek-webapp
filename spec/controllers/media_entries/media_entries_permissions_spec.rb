require 'spec_helper'

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
            { id: @media_entry.id },
            user_id: @user.id
      end.to raise_error(Errors::ForbiddenError)
    end

    it 'for update' do
      expect do
        put :permissions_update,
            { id: @media_entry.id,
              user_permissions: [{ user_id: create(:user).id,
                                   get_metadata_and_previews: true }] },
            user_id: @user.id
      end.to raise_error(Errors::ForbiddenError)
    end
  end

  it 'updates successfully' do
    media_entry = FactoryGirl.create(:media_entry,
                                     responsible_user: @user)
    media_entry.user_permissions << \
      (up1 = FactoryGirl.create(:media_entry_user_permission,
                                user: create(:user)))
    media_entry.user_permissions << \
      (up2 = FactoryGirl.create(:media_entry_user_permission,
                                user: create(:user)))
    media_entry.group_permissions << \
      (gp1 = FactoryGirl.create(:media_entry_group_permission,
                                group: create(:group)))
    media_entry.group_permissions << \
      (gp2 = FactoryGirl.create(:media_entry_group_permission,
                                group: create(:group)))
    media_entry.api_client_permissions << \
      (apc1 = FactoryGirl.create(:media_entry_api_client_permission,
                                 api_client: create(:api_client)))
    media_entry.api_client_permissions << \
      (apc2 = FactoryGirl.create(:media_entry_api_client_permission,
                                 api_client: create(:api_client)))

    update_params = \
      { id: media_entry.id,
        media_entry:
          { user_permissions:
              [{ user_id: up1.user_id,
                 get_metadata_and_previews: \
                    (not up1.get_metadata_and_previews) },
               { user_id: up2.user_id },
               { user_id: (user = create(:user)).id,
                 get_metadata_and_previews: true }],
            group_permissions:
              [{ group_id: gp1.group_id,
                 get_metadata_and_previews: \
                    (not gp1.get_metadata_and_previews) },
               { group_id: gp2.group_id },
               { group_id: (group = create(:group)).id,
                 get_metadata_and_previews: true }],
            api_client_permissions:
              [{ api_client_id: apc1.api_client_id,
                 get_metadata_and_previews: \
                    (not apc1.get_metadata_and_previews) },
               { api_client_id: apc2.api_client_id },
               { api_client_id: (api_client = create(:api_client)).id,
                 get_metadata_and_previews: true }],
            get_metadata_and_previews: \
              (not media_entry.get_metadata_and_previews),
            get_full_size: (not media_entry.get_full_size)
          }
      }

    put :permissions_update,
        update_params,
        user_id: @user.id

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

  it 'raises if empty array' do
    media_entry = FactoryGirl.create(:media_entry,
                                     responsible_user: @user)
    update_params = \
      { id: media_entry.id,
        media_entry:
          { user_permissions: 'not an array' } }

    expect do
      put :permissions_update, update_params, user_id: @user.id
    end.to raise_error Errors::InvalidParameterValue
  end

  it 'deletes old permissions if no new provided' do
    media_entry = FactoryGirl.create(:media_entry,
                                     responsible_user: @user)
    media_entry.user_permissions << \
      FactoryGirl.create(:media_entry_user_permission,
                         user: create(:user))
    media_entry.group_permissions << \
      FactoryGirl.create(:media_entry_group_permission,
                         group: create(:group))
    media_entry.api_client_permissions << \
      FactoryGirl.create(:media_entry_api_client_permission,
                         api_client: create(:api_client))

    update_params = \
      { id: media_entry.id,
        media_entry:
         { get_metadata_and_previews: true,
           get_full_size: true } }

    put :permissions_update, update_params, user_id: @user.id

    media_entry.reload
    expect(media_entry.user_permissions.count).to be == 0
    expect(media_entry.group_permissions.count).to be == 0
    expect(media_entry.api_client_permissions.count).to be == 0
  end
end
