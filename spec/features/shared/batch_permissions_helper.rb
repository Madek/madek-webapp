# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/LineLength

module BatchPermissionsHelper

  # CASE 1: permission key for both entries has 'true' value and should stay unchanged
  # CASE 2: permission key for both entries has 'false' value and should stay unchanged
  # CASE 3: permission key for both entries has different value and should stay unchanged
  # CASE 4: permission key for both entries has different value and should become 'true'
  # CASE 5: permission key for both entries has different value and should become 'false'
  # CASE 6: permission key for both entries has 'true' value and should become 'false'
  # CASE 7: permission key for both entries has 'false' value and should become 'true'
  # CASE 8: permission is existing for only one of the entries and none of the permission keys is changed
  #   => for both entries it remains unchanged (no permission is created for the entry without it)
  # CASE 9: permission is existing for only one of the entries and a permission key is changed from 'true' to 'false'
  #   => it should be updated accordingly for the existing permission
  #      and it should be created for the second one with the same values for all permission keys
  # CASE 10: permission is not existing for any of the entries => it should be created for both
  # CASE 11: permission is existing for both entries and should be deleted
  # CASE 12: public permission for both entries has different value and should stay unchanged
  # CASE 13: public permission for both entries has different value and should become true

  def setup_batch_permissions_test_data
    @logged_in_user = create(:user, password: 'password')

    # entry, also CASE 12+13
    @entry_1 = FactoryGirl.create(:media_entry,
                                  responsible_user: @logged_in_user,
                                  get_full_size: false,
                                  get_metadata_and_previews: true)
    @entry_2 = FactoryGirl.create(:media_entry,
                                  responsible_user: @logged_in_user,
                                  get_metadata_and_previews: false)

    # CASE 1
    @case_1_user = FactoryGirl.create(:user)
    @case_1_user_permission_1 = create(:media_entry_user_permission,
                                       media_entry: @entry_1,
                                       user: @case_1_user,
                                       get_metadata_and_previews: true)
    @case_1_user_permission_2 = create(:media_entry_user_permission,
                                       media_entry: @entry_2,
                                       user: @case_1_user,
                                       get_metadata_and_previews: true)

    # CASE 2
    @case_2_group = FactoryGirl.create(:group)
    @case_2_group_permission_1 = create(:media_entry_group_permission,
                                        media_entry: @entry_1,
                                        group: @case_2_group,
                                        get_full_size: false)
    @case_2_group_permission_2 = create(:media_entry_group_permission,
                                        media_entry: @entry_2,
                                        group: @case_2_group,
                                        get_full_size: false)
    @case_2_api_client = FactoryGirl.create(:api_client)
    @case_2_api_client_permission_1 = create(:media_entry_api_client_permission,
                                             media_entry: @entry_1,
                                             api_client: @case_2_api_client,
                                             get_full_size: false)
    @case_2_api_client_permission_2 = create(:media_entry_api_client_permission,
                                             media_entry: @entry_2,
                                             api_client: @case_2_api_client,
                                             get_full_size: false)

    # CASE 3
    @case_3_user = FactoryGirl.create(:user)
    @case_3_user_permission_1 = create(:media_entry_user_permission,
                                       media_entry: @entry_1,
                                       user: @case_3_user,
                                       edit_metadata: true)
    @case_3_user_permission_2 = create(:media_entry_user_permission,
                                       media_entry: @entry_2,
                                       user: @case_3_user,
                                       edit_metadata: false)

    # CASE 4
    @case_4_user = FactoryGirl.create(:user)
    @case_4_user_permission_1 = create(:media_entry_user_permission,
                                       media_entry: @entry_1,
                                       user: @case_4_user,
                                       edit_permissions: true)
    @case_4_user_permission_2 = create(:media_entry_user_permission,
                                       media_entry: @entry_2,
                                       user: @case_4_user,
                                       edit_permissions: false)

    # CASE 5
    @case_5_group = FactoryGirl.create(:group)
    @case_5_group_permission_1 = create(:media_entry_group_permission,
                                        media_entry: @entry_1,
                                        group: @case_5_group,
                                        get_metadata_and_previews: true)
    @case_5_group_permission_2 = create(:media_entry_group_permission,
                                        media_entry: @entry_2,
                                        group: @case_5_group,
                                        get_metadata_and_previews: false)

    @case_5_api_client = FactoryGirl.create(:api_client)
    @case_5_api_client_permission_1 = create(:media_entry_api_client_permission,
                                             media_entry: @entry_1,
                                             api_client: @case_5_api_client,
                                             get_metadata_and_previews: true)
    @case_5_api_client_permission_2 = create(:media_entry_api_client_permission,
                                             media_entry: @entry_2,
                                             api_client: @case_5_api_client,
                                             get_metadata_and_previews: false)

    # CASE 6
    @case_6_user = FactoryGirl.create(:user)
    @case_6_user_permission_1 = create(:media_entry_user_permission,
                                       media_entry: @entry_1,
                                       user: @case_6_user,
                                       get_metadata_and_previews: true)
    @case_6_user_permission_2 = create(:media_entry_user_permission,
                                       media_entry: @entry_2,
                                       user: @case_6_user,
                                       get_metadata_and_previews: true)

    # CASE 7
    @case_7_user = FactoryGirl.create(:user)
    @case_7_user_permission_1 = create(:media_entry_user_permission,
                                       media_entry: @entry_1,
                                       user: @case_7_user,
                                       get_metadata_and_previews: false)
    @case_7_user_permission_2 = create(:media_entry_user_permission,
                                       media_entry: @entry_2,
                                       user: @case_7_user,
                                       get_metadata_and_previews: false)

    # CASE 8:
    @case_8_user = FactoryGirl.create(:user)
    @case_8_user_permission_1 = create(:media_entry_user_permission,
                                       media_entry: @entry_1,
                                       user: @case_8_user)

    # CASE 9:
    @case_9_group = FactoryGirl.create(:group)
    @case_9_group_permission_1 = create(:media_entry_group_permission,
                                        media_entry: @entry_1,
                                        group: @case_9_group,
                                        get_metadata_and_previews: true)

    @case_9_api_client = FactoryGirl.create(:api_client)
    @case_9_api_client_permission_1 = create(:media_entry_api_client_permission,
                                             media_entry: @entry_1,
                                             api_client: @case_9_api_client,
                                             get_metadata_and_previews: true)

    # CASE 10:
    @case_10_user = FactoryGirl.create(:user)
    @case_10_group = FactoryGirl.create(:group)
    @case_10_api_client = FactoryGirl.create(:api_client)

    # CASE 11
    @case_11_user = FactoryGirl.create(:user)
    @case_11_user_permission_1 = create(:media_entry_user_permission,
                                        media_entry: @entry_1,
                                        user: @case_11_user)
    @case_11_user_permission_2 = create(:media_entry_user_permission,
                                        media_entry: @entry_2,
                                        user: @case_11_user)
    @case_11_group = FactoryGirl.create(:group)
    @case_11_group_permission_1 = create(:media_entry_group_permission,
                                         media_entry: @entry_1,
                                         group: @case_11_group)
    @case_11_group_permission_2 = create(:media_entry_group_permission,
                                         media_entry: @entry_2,
                                         group: @case_11_group)
  end

  def check_batch_permissions_results
    # CASE 1
    case_1_user_permission_1_dup = @case_1_user_permission_1.dup
    case_1_user_permission_2_dup = @case_1_user_permission_2.dup
    @case_1_user_permission_1.reload
    @case_1_user_permission_2.reload
    expect(@case_1_user_permission_1.get_metadata_and_previews)
      .to be == case_1_user_permission_1_dup.get_metadata_and_previews
    expect(@case_1_user_permission_2.get_metadata_and_previews)
      .to be == case_1_user_permission_2_dup.get_metadata_and_previews

    # CASE 2
    case_2_group_permission_1_dup = @case_2_group_permission_1.dup
    case_2_group_permission_2_dup = @case_2_group_permission_2.dup
    @case_2_group_permission_1.reload
    @case_2_group_permission_2.reload
    expect(@case_2_group_permission_1.get_full_size)
      .to be == case_2_group_permission_1_dup.get_full_size
    expect(@case_2_group_permission_2.get_full_size)
      .to be == case_2_group_permission_2_dup.get_full_size

    case_2_api_client_permission_1_dup = @case_2_api_client_permission_1.dup
    case_2_api_client_permission_2_dup = @case_2_api_client_permission_2.dup
    @case_2_api_client_permission_1.reload
    @case_2_api_client_permission_2.reload
    expect(@case_2_api_client_permission_1.get_full_size)
      .to be == case_2_api_client_permission_1_dup.get_full_size
    expect(@case_2_api_client_permission_2.get_full_size)
      .to be == case_2_api_client_permission_2_dup.get_full_size

    # CASE 3
    case_3_user_permission_1_dup = @case_3_user_permission_1.dup
    case_3_user_permission_2_dup = @case_3_user_permission_2.dup
    @case_3_user_permission_1.reload
    @case_3_user_permission_2.reload
    expect(@case_3_user_permission_1.edit_metadata)
      .to be == case_3_user_permission_1_dup.edit_metadata
    expect(@case_3_user_permission_2.edit_metadata)
      .to be == case_3_user_permission_2_dup.edit_metadata

    # CASE 4
    @case_4_user_permission_1.reload
    @case_4_user_permission_2.reload
    expect(@case_4_user_permission_1.edit_permissions).to be == true
    expect(@case_4_user_permission_2.edit_permissions).to be == true

    # CASE 5
    @case_5_group_permission_1.reload
    @case_5_group_permission_2.reload
    expect(@case_5_group_permission_1.get_metadata_and_previews).to be == false
    expect(@case_5_group_permission_2.get_metadata_and_previews).to be == false

    @case_5_api_client_permission_1.reload
    @case_5_api_client_permission_2.reload
    expect(@case_5_api_client_permission_1.get_metadata_and_previews)
      .to be == false
    expect(@case_5_api_client_permission_2.get_metadata_and_previews)
      .to be == false

    # CASE 6
    @case_6_user_permission_1.reload
    @case_6_user_permission_2.reload
    expect(@case_6_user_permission_1.get_metadata_and_previews).to be == false
    expect(@case_6_user_permission_2.get_metadata_and_previews).to be == false

    # CASE 7
    @case_7_user_permission_1.reload
    @case_7_user_permission_2.reload
    expect(@case_7_user_permission_1.get_metadata_and_previews).to be == true
    expect(@case_7_user_permission_2.get_metadata_and_previews).to be == true

    # CASE 8
    case_8_user_permission_1_dup = @case_8_user_permission_1.dup
    @case_8_user_permission_1.reload
    expect(@case_8_user_permission_1.get_metadata_and_previews)
      .to be == case_8_user_permission_1_dup.get_metadata_and_previews
    expect(@entry_2.user_permissions.find_by_user_id @case_8_user).not_to be

    # CASE 9
    @case_9_group_permission_1.reload
    expect(@case_9_group_permission_1.get_full_size).to be == false
    expect(
      @entry_2.group_permissions.find_by_group_id(@case_9_group)
      .get_full_size
    ).to be == false

    @case_9_api_client_permission_1.reload
    expect(@case_9_api_client_permission_1.get_full_size).to be == false
    expect(
      @entry_2.api_client_permissions.find_by_api_client_id(@case_9_api_client)
      .get_full_size
    ).to be == false

    # CASE 10
    expect(
      @entry_1.user_permissions
      .where(user_id: @case_10_user,
             get_metadata_and_previews: true,
             get_full_size: true,
             edit_metadata: false,
             edit_permissions: false)
      .first
    ).to be
    expect(
      @entry_2.user_permissions
      .where(user_id: @case_10_user,
             get_metadata_and_previews: true,
             get_full_size: true,
             edit_metadata: false,
             edit_permissions: false)
      .first
    ).to be
    expect(
      @entry_1.group_permissions
      .where(group_id: @case_10_group,
             get_metadata_and_previews: true,
             get_full_size: true,
             edit_metadata: false)
      .first
    ).to be
    expect(
      @entry_2.group_permissions
      .where(group_id: @case_10_group,
             get_metadata_and_previews: true,
             get_full_size: true,
             edit_metadata: false)
      .first
    ).to be
    expect(
      @entry_1.api_client_permissions
      .where(api_client_id: @case_10_api_client,
             get_metadata_and_previews: true,
             get_full_size: true)
      .first
    ).to be
    expect(
      @entry_2.api_client_permissions
      .where(api_client_id: @case_10_api_client,
             get_metadata_and_previews: true,
             get_full_size: true)
      .first
    ).to be

    # CASE 11
    expect { @case_11_user_permission_1.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_user_permission_2.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_group_permission_1.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_group_permission_2.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect(@entry_1.user_permissions.reload.count).to be == 7
    expect(@entry_2.user_permissions.reload.count).to be == 6
    expect(@entry_1.group_permissions.reload.count).to be == 4
    expect(@entry_2.group_permissions.reload.count).to be == 4
    expect(@entry_1.api_client_permissions.reload.count).to be == 4
    expect(@entry_2.api_client_permissions.reload.count).to be == 4

    # CASE 12
    expect(@entry_1.reload.get_metadata_and_previews).to be == true
    expect(@entry_2.reload.get_metadata_and_previews).to be == false

    # CASE 13
    expect(@entry_1.reload.get_full_size).to be == true
    expect(@entry_2.reload.get_full_size).to be == true
  end
end
