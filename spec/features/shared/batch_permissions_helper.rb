# rubocop:disable Metrics/ModuleLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/LineLength

module BatchPermissionsHelper

  # CASE 1: permission key for both res. has 'true' value and should stay unchanged
  # CASE 2: permission key for both res. has 'false' value and should stay unchanged
  # CASE 3: permission key for both res. has different value and should stay unchanged
  # CASE 4: permission key for both res. has different value and should become 'true'
  # CASE 5: permission key for both res. has different value and should become 'false'
  # CASE 6: permission key for both res. has 'true' value and should become 'false'
  # CASE 7: permission key for both res. has 'false' value and should become 'true'
  # CASE 8: permission is existing for only one of the res. and none of the permission keys is changed
  #   => for both res. it remains unchanged (no permission is created for the entry without it)
  # CASE 9: permission is existing for only one of the res. and a permission key is changed from 'true' to 'false'
  #   => it should be updated accordingly for the existing permission
  #      and it should be created for the second one with the same values for all permission keys
  # CASE 10: permission is not existing for any of the res. => it should be created for both
  # CASE 11: permission is existing for both res. and should be deleted
  # CASE 12: public permission for both res. has different value and should become true
  # CASE 13 (only MediaEntries): public permission for both res. has different value and should stay unchanged

  def setup_batch_permissions_test_data(resource_class)
    throw ArgumentError unless resource_class.is_a?(Class)
    @logged_in_user = create(:user, password: 'password')

    # main resource, also CASE 12+13
    case resource_class.name
    when 'MediaEntry'
      @resource_1 = FactoryGirl.create(
        :media_entry,
        responsible_user: @logged_in_user,
        get_full_size: true,
        get_metadata_and_previews: false)
      @resource_2 = FactoryGirl.create(
        :media_entry,
        responsible_user: @logged_in_user,
        get_full_size: false,
        get_metadata_and_previews: true)

    when 'Collection'
      @resource_1 = FactoryGirl.create(
        :collection,
        responsible_user: @logged_in_user,
        get_metadata_and_previews: true)
      @resource_2 = FactoryGirl.create(
        :collection,
        responsible_user: @logged_in_user,
        get_metadata_and_previews: false)
    end

    # CASE 1
    @case_1_user = FactoryGirl.create(:user)
    @case_1_delegation = FactoryGirl.create(:delegation)
    @case_1_user_permission_1 = _create_perm(
      @resource_1, @case_1_user, get_metadata_and_previews: true)
    @case_1_user_permission_2 = _create_perm(
      @resource_2, @case_1_user, get_metadata_and_previews: true)
    @case_1_user_permission_3 = _create_perm(
      @resource_1, @case_1_delegation, get_metadata_and_previews: true)
    @case_1_user_permission_4 = _create_perm(
      @resource_2, @case_1_delegation, get_metadata_and_previews: true)

    # CASE 2
    @case_2_group = FactoryGirl.create(:group)
    @case_2_group_permission_1 = _create_perm(
      @resource_1, @case_2_group, get_metadata_and_previews: false)
    @case_2_group_permission_2 = _create_perm(
      @resource_2, @case_2_group, get_metadata_and_previews: false)
    @case_2_api_client = FactoryGirl.create(:api_client)
    @case_2_api_client_permission_1 = _create_perm(
      @resource_1, @case_2_api_client, get_metadata_and_previews: false)
    @case_2_api_client_permission_2 = _create_perm(
      @resource_2, @case_2_api_client, get_metadata_and_previews: false)

    # CASE 3
    @case_3_user = FactoryGirl.create(:user)
    @case_3_user_permission_1 = _create_perm(
      @resource_1, @case_3_user, get_metadata_and_previews: true)
    @case_3_user_permission_2 = _create_perm(
      @resource_2, @case_3_user, get_metadata_and_previews: false)

    # CASE 4
    @case_4_user = FactoryGirl.create(:user)
    @case_4_user_permission_1 = _create_perm(
      @resource_1, @case_4_user,
      edit_permissions: true)
    @case_4_user_permission_2 = _create_perm(
      @resource_2, @case_4_user,
      edit_permissions: false)

    # CASE 5
    @case_5_group = FactoryGirl.create(:group)
    @case_5_group_permission_1 = _create_perm(
      @resource_1, @case_5_group,
      get_metadata_and_previews: true)
    @case_5_group_permission_2 = _create_perm(
      @resource_2, @case_5_group,
      get_metadata_and_previews: false)

    @case_5_api_client = FactoryGirl.create(:api_client)
    @case_5_api_client_permission_1 = _create_perm(
      @resource_1, @case_5_api_client,
      get_metadata_and_previews: true)
    @case_5_api_client_permission_2 = _create_perm(
      @resource_2, @case_5_api_client,
      get_metadata_and_previews: false)

    # CASE 6
    @case_6_user = FactoryGirl.create(:user)
    @case_6_user_permission_1 = _create_perm(
      @resource_1, @case_6_user,
      get_metadata_and_previews: true)
    @case_6_user_permission_2 = _create_perm(
      @resource_2, @case_6_user,
      get_metadata_and_previews: true)

    # CASE 7
    @case_7_user = FactoryGirl.create(:user)
    @case_7_user_permission_1 = _create_perm(
      @resource_1, @case_7_user,
      get_metadata_and_previews: false)
    @case_7_user_permission_2 = _create_perm(
      @resource_2, @case_7_user,
      get_metadata_and_previews: false)

    # CASE 8:
    @case_8_user = FactoryGirl.create(:user)
    @case_8_user_permission_1 = _create_perm(@resource_1, @case_8_user)

    # CASE 9:
    @case_9_group = FactoryGirl.create(:group)
    @case_9_group_permission_1 = _create_perm(
      @resource_1, @case_9_group,
      get_metadata_and_previews: true)

    @case_9_api_client = FactoryGirl.create(:api_client)
    @case_9_api_client_permission_1 = _create_perm(
      @resource_1, @case_9_api_client,
      get_metadata_and_previews: true)

    # CASE 10:
    @case_10_user = FactoryGirl.create(:user)
    @case_10_group = FactoryGirl.create(:group)
    @case_10_api_client = FactoryGirl.create(:api_client)
    @case_10_delegation = FactoryGirl.create(:delegation)

    # CASE 11
    @case_11_user = FactoryGirl.create(:user)
    @case_11_delegation = FactoryGirl.create(:delegation)
    @case_11_user_permission_1 = _create_perm(@resource_1, @case_11_user)
    @case_11_user_permission_2 = _create_perm(@resource_2, @case_11_user)
    @case_11_user_delegation_permission_3 = _create_perm(@resource_1, @case_11_delegation)
    @case_11_user_delegation_permission_4 = _create_perm(@resource_2, @case_11_delegation)
    @case_11_group = FactoryGirl.create(:group)
    @case_11_group_permission_1 = _create_perm(@resource_1, @case_11_group)
    @case_11_group_permission_2 = _create_perm(@resource_2, @case_11_group)
  end

  def check_batch_permissions_results(resource_class)
    # CASE 1
    case_1_user_permission_1_dup = @case_1_user_permission_1.dup
    case_1_user_permission_2_dup = @case_1_user_permission_2.dup
    case_1_user_permission_3_dup = @case_1_user_permission_1.dup
    case_1_user_permission_4_dup = @case_1_user_permission_2.dup
    @case_1_user_permission_1.reload
    @case_1_user_permission_2.reload
    @case_1_user_permission_3.reload
    @case_1_user_permission_4.reload
    expect(@case_1_user_permission_1.get_metadata_and_previews)
      .to be == case_1_user_permission_1_dup.get_metadata_and_previews
    expect(@case_1_user_permission_2.get_metadata_and_previews)
      .to be == case_1_user_permission_2_dup.get_metadata_and_previews
    expect(@case_1_user_permission_3.get_metadata_and_previews)
      .to be == case_1_user_permission_3_dup.get_metadata_and_previews
    expect(@case_1_user_permission_4.get_metadata_and_previews)
      .to be == case_1_user_permission_4_dup.get_metadata_and_previews

    # CASE 2
    if resource_class == MediaEntry
      case_2_group_permission_1_dup = @case_2_group_permission_1.dup
      case_2_group_permission_2_dup = @case_2_group_permission_2.dup
      @case_2_group_permission_1.reload
      @case_2_group_permission_2.reload
      expect(@case_2_group_permission_1.get_metadata_and_previews)
        .to be == case_2_group_permission_1_dup.get_metadata_and_previews
      expect(@case_2_group_permission_2.get_metadata_and_previews)
        .to be == case_2_group_permission_2_dup.get_metadata_and_previews

      case_2_api_client_permission_1_dup = @case_2_api_client_permission_1.dup
      case_2_api_client_permission_2_dup = @case_2_api_client_permission_2.dup
      @case_2_api_client_permission_1.reload
      @case_2_api_client_permission_2.reload
      expect(@case_2_api_client_permission_1.get_metadata_and_previews)
        .to be == case_2_api_client_permission_1_dup.get_metadata_and_previews
      expect(@case_2_api_client_permission_2.get_metadata_and_previews)
        .to be == case_2_api_client_permission_2_dup.get_metadata_and_previews
    end

    # CASE 3
    case_3_user_permission_1_dup = @case_3_user_permission_1.dup
    case_3_user_permission_2_dup = @case_3_user_permission_2.dup
    @case_3_user_permission_1.reload
    @case_3_user_permission_2.reload
    expect(@case_3_user_permission_1.get_metadata_and_previews)
      .to be == case_3_user_permission_1_dup.get_metadata_and_previews
    expect(@case_3_user_permission_2.get_metadata_and_previews)
      .to be == case_3_user_permission_2_dup.get_metadata_and_previews

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
    expect(@resource_2.user_permissions.find_by_user_id @case_8_user).not_to be

    # CASE 9
    @case_9_group_permission_1.reload
    expect(@case_9_group_permission_1.get_metadata_and_previews).to be == false
    expect(
      @resource_2.group_permissions.find_by_group_id(@case_9_group)
      .get_metadata_and_previews
    ).to be == false

    @case_9_api_client_permission_1.reload
    expect(@case_9_api_client_permission_1.get_metadata_and_previews).to be == false
    expect(
      @resource_2.api_client_permissions.find_by_api_client_id(@case_9_api_client)
      .get_metadata_and_previews
    ).to be == false

    # CASE 10
    if resource_class == MediaEntry
      expect(
        @resource_1.user_permissions
        .where(user_id: @case_10_user,
               get_metadata_and_previews: true,
               get_full_size: true,
               edit_metadata: true,
               edit_permissions: true)
        .first
      ).to be
      expect(
        @resource_2.user_permissions
        .where(user_id: @case_10_user,
               get_metadata_and_previews: true,
               get_full_size: true,
               edit_metadata: true,
               edit_permissions: true)
        .first
      ).to be
      expect(
        @resource_1.group_permissions
        .where(group_id: @case_10_group,
               get_metadata_and_previews: true,
               get_full_size: false,
               edit_metadata: false)
        .first
      ).to be
      expect(
        @resource_2.group_permissions
        .where(group_id: @case_10_group,
               get_metadata_and_previews: true,
               get_full_size: false,
               edit_metadata: false)
        .first
      ).to be
      expect(
        @resource_1.api_client_permissions
        .where(api_client_id: @case_10_api_client,
               get_metadata_and_previews: true,
               get_full_size: false)
        .first
      ).to be
      expect(
        @resource_2.api_client_permissions
        .where(api_client_id: @case_10_api_client,
               get_metadata_and_previews: true,
               get_full_size: false)
        .first
      ).to be
      expect(
        @resource_1.user_permissions
        .where(delegation_id: @case_10_delegation,
               get_metadata_and_previews: true,
               get_full_size: false,
               edit_metadata: false,
               edit_permissions: false)
        .first
      ).to be
      expect(
        @resource_2.user_permissions
        .where(delegation_id: @case_10_delegation,
               get_metadata_and_previews: true,
               get_full_size: false,
               edit_metadata: false,
               edit_permissions: false)
        .first
      ).to be
    else
      expect(
        @resource_1.user_permissions
        .where(user_id: @case_10_user,
               get_metadata_and_previews: true,
               edit_metadata_and_relations: true,
               edit_permissions: true)
        .first
      ).to be
      expect(
        @resource_2.user_permissions
        .where(user_id: @case_10_user,
               get_metadata_and_previews: true,
               edit_metadata_and_relations: true,
               edit_permissions: true)
        .first
      ).to be
      expect(
        @resource_1.user_permissions
        .where(delegation_id: @case_10_delegation,
               get_metadata_and_previews: true,
               edit_metadata_and_relations: false,
               edit_permissions: false)
        .first
      ).to be
      expect(
        @resource_2.user_permissions
        .where(delegation_id: @case_10_delegation,
               get_metadata_and_previews: true,
               edit_metadata_and_relations: false,
               edit_permissions: false)
        .first
      ).to be
      expect(
        @resource_1.group_permissions
        .where(group_id: @case_10_group,
               get_metadata_and_previews: true,
               edit_metadata_and_relations: false)
        .first
      ).to be
      expect(
        @resource_2.group_permissions
        .where(group_id: @case_10_group,
               get_metadata_and_previews: true,
               edit_metadata_and_relations: false)
        .first
      ).to be
      expect(
        @resource_1.api_client_permissions
        .where(api_client_id: @case_10_api_client,
               get_metadata_and_previews: true)
        .first
      ).to be
      expect(
        @resource_2.api_client_permissions
        .where(api_client_id: @case_10_api_client,
               get_metadata_and_previews: true)
        .first
      ).to be
    end

    # CASE 11
    expect { @case_11_user_permission_1.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_user_permission_2.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_user_delegation_permission_3.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_user_delegation_permission_4.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_group_permission_1.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect { @case_11_group_permission_2.reload }
      .to raise_error ActiveRecord::RecordNotFound
    expect(@resource_1.user_permissions.reload.count).to be == 9
    expect(@resource_2.user_permissions.reload.count).to be == 8
    expect(@resource_1.group_permissions.reload.count).to be == 4
    expect(@resource_2.group_permissions.reload.count).to be == 4
    expect(@resource_1.api_client_permissions.reload.count).to be == 4
    expect(@resource_2.api_client_permissions.reload.count).to be == 4

    # CASE 12
    expect(@resource_1.reload.get_metadata_and_previews).to be == true
    expect(@resource_2.reload.get_metadata_and_previews).to be == true

    # CASE 13 (only MediaEntries)
    if resource_class == MediaEntry
      expect(@resource_1.reload.get_full_size).to be == true
      expect(@resource_2.reload.get_full_size).to be == false
    end
  end

  def _create_perm(resource, subject, opts = {})
    res_klass = resource.class.name.underscore
    subj_klass = subject.class.name.underscore

    FactoryGirl.create(
      "#{res_klass}_#{subj_klass}_permission".to_sym,
      opts.merge(res_klass => resource, subj_klass => subject))
  end
end
