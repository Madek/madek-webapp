require 'spec_helper'

describe CollectionsController do
  before :example do
    @user = create(:user)
  end

  it 'updates successfully' do
    collection = FactoryGirl.create(:collection,
                                    responsible_user: @user)
    collection.user_permissions << \
      (up1 = FactoryGirl.create(:collection_user_permission,
                                user: create(:user)))
    collection.user_permissions << \
      (up2 = FactoryGirl.create(:collection_user_permission,
                                user: create(:user)))
    collection.group_permissions << \
      (gp1 = FactoryGirl.create(:collection_group_permission,
                                group: create(:group)))
    collection.group_permissions << \
      (gp2 = FactoryGirl.create(:collection_group_permission,
                                group: create(:group)))
    collection.api_client_permissions << \
      (apc1 = FactoryGirl.create(:collection_api_client_permission,
                                 api_client: create(:api_client)))
    collection.api_client_permissions << \
      (apc2 = FactoryGirl.create(:collection_api_client_permission,
                                 api_client: create(:api_client)))

    update_params = \
      { id: collection.id,
        collection:
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
                (not collection.get_metadata_and_previews) } }
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
      collection.user_permissions.find_by(user_id: up1.user_id)
        .get_metadata_and_previews
    ).to be (not up1.get_metadata_and_previews)
    expect(
      collection.user_permissions.find_by(user_id: user.id)
        .get_metadata_and_previews
    ).to be true
    expect(
      collection.group_permissions.find_by(group_id: gp1.group_id)
        .get_metadata_and_previews
    ).to be (not gp1.get_metadata_and_previews)
    expect(
      collection.group_permissions.find_by(group_id: group.id)
        .get_metadata_and_previews
    ).to be true
    expect(
      collection.api_client_permissions.find_by(api_client_id: apc1.api_client_id)
        .get_metadata_and_previews
    ).to be (not apc1.get_metadata_and_previews)
    expect(
      collection.api_client_permissions.find_by(api_client_id: api_client.id)
        .get_metadata_and_previews
    ).to be true

    # check the correct amount of permissions
    expect(collection.user_permissions.count).to be == 2
    expect(collection.group_permissions.count).to be == 2
    expect(collection.api_client_permissions.count).to be == 2

    # check public permissions
    old = collection.clone
    collection.reload
    expect(collection.get_metadata_and_previews)
      .to be (not old.get_metadata_and_previews)
  end

  it 'raises if empty array' do
    collection = FactoryGirl.create(:collection,
                                    responsible_user: @user)
    update_params = \
      { id: collection.id,
        collection:
          { user_permissions: 'not an array' } }

    expect do
      put :permissions_update, params: update_params, session: { user_id: @user.id }
    end.to raise_error Errors::InvalidParameterValue
  end

  it 'deletes old permissions if no new provided' do
    collection = FactoryGirl.create(:collection,
                                    responsible_user: @user)
    collection.user_permissions << \
      FactoryGirl.create(:collection_user_permission,
                         user: create(:user))
    collection.group_permissions << \
      FactoryGirl.create(:collection_group_permission,
                         group: create(:group))
    collection.api_client_permissions << \
      FactoryGirl.create(:collection_api_client_permission,
                         api_client: create(:api_client))

    update_params = \
      { id: collection.id,
        collection: {
          public_permission: {
            get_metadata_and_previews: true,
            get_full_size: true } } }

    put :permissions_update, params: update_params, session: { user_id: @user.id }

    collection.reload
    expect(collection.user_permissions.count).to be == 0
    expect(collection.group_permissions.count).to be == 0
    expect(collection.api_client_permissions.count).to be == 0
  end
end
