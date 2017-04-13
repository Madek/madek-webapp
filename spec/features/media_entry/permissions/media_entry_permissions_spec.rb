require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry' do
  background do
    @user = User.find_by(login: 'normin')
    @entry = FactoryGirl.create(:media_entry_with_image_media_file,
                                responsible_user: @user)

  end

  scenario 'edit permissions (some perms for user, group, client)' do
    sign_in_as @user.login
    open_permission_editable

    test_perm = permission_types[0]
    other_perm = permission_types[1]

    add_subject_with_permission(@node_people, 'Norbert', test_perm)
    add_subject_with_permission(@node_groups, 'Diplomarbeitsg', test_perm)
    add_subject_with_permission(@node_apiapps, 'fancy', test_perm)

    @node_form.click_on(I18n.t(:permissions_table_save_btn))
    @entry.reload

    expect(current_path).to eq permissions_media_entry_path(@entry)

    expect(@entry.user_permissions.length).to eq 1
    expect(@entry.user_permissions.first[test_perm]).to be true
    expect(@entry.user_permissions.first[other_perm]).to be false

    expect(@entry.group_permissions.length).to eq 1
    expect(@entry.group_permissions.first[test_perm]).to be true
    expect(@entry.group_permissions.first[other_perm]).to be false

    expect(@entry.api_client_permissions.length).to eq 1
    expect(@entry.api_client_permissions.first[test_perm]).to be true
    expect(@entry.api_client_permissions.first[other_perm]).to be false
  end

  example \
    'edit permissions as entrusted user (full perms for user, group, client)' \
  do
    @another_user = User.find_by(login: 'adam')
    create(
      :media_entry_user_permission,
      media_entry: @entry, user: @another_user,
      get_metadata_and_previews: true, get_full_size: true,
      edit_metadata: true, edit_permissions: true)

    sign_in_as @another_user.login

    open_permission_editable

    user_permissions_count = @entry.user_permissions.count
    group_permissions_count = @entry.group_permissions.count
    api_permissions_count = @entry.api_client_permissions.count

    user_perms = permission_types
    group_perms = permission_types.first(3)
    api_perms = permission_types.first(2)

    user_perms.each do |perm|
      add_subject_with_permission(@node_people, 'Norbert', perm)
    end
    group_perms.each do |perm|
      add_subject_with_permission(@node_groups, 'Diplomarbeitsg', perm)
    end
    api_perms.each do |perm|
      add_subject_with_permission(@node_apiapps, 'fancy', perm)
    end

    @node_form.click_on(I18n.t(:permissions_table_save_btn))
    @entry.reload

    expect(current_path).to eq permissions_media_entry_path(@entry)

    expect(@entry.user_permissions.length).to eq (user_permissions_count + 1)
    expect(@entry.user_permissions.first.attributes.slice(*permission_types))
      .to eq user_perms.map { |k| [k, true] }.to_h

    expect(@entry.group_permissions.length).to eq (group_permissions_count + 1)
    expect(@entry.group_permissions.first.attributes.slice(*permission_types))
      .to eq group_perms.map { |k| [k, true] }.to_h

    expect(@entry.api_client_permissions.length).to eq (api_permissions_count + 1)
    expect(@entry.api_client_permissions.first.attributes.slice(*permission_types))
      .to eq api_perms.map { |k| [k, true] }.to_h

  end

  scenario 'weaker permissions are set by higher ones' do
    sign_in_as @user.login
    open_permission_editable

    perm_1 = permission_types[0]
    perm_2 = permission_types[1]
    perm_3 = permission_types[2]
    perm_4 = permission_types[3]

    add_subject_with_permission(@node_people, 'Norbert', perm_3)

    @node_form.click_on(I18n.t(:permissions_table_save_btn))
    @entry.reload

    expect(current_path).to eq permissions_media_entry_path(@entry)

    expect(@entry.user_permissions.length).to eq 1
    expect(@entry.user_permissions.first[perm_1]).to be true
    expect(@entry.user_permissions.first[perm_2]).to be true
    expect(@entry.user_permissions.first[perm_3]).to be true
    expect(@entry.user_permissions.first[perm_4]).to be false
  end

  scenario 'subjects can\'t be added twice' do
    sign_in_as @user.login
    open_permission_editable
    expect(@entry.user_permissions.length).to eq 0

    add_subject_with_permission(@node_people, 'Norbert', permission_types[3])
    # NOTE: the helper clicks twice so last checkbox is disabled. thats ok.
    add_subject_with_permission(@node_people, 'Norbert', permission_types[3])
    @node_form.click_on(I18n.t(:permissions_table_save_btn))
    @entry.reload

    expect(current_path).to eq permissions_media_entry_path(@entry)

    expect(@entry.user_permissions.length).to eq 1
    expect(@entry.user_permissions.first.user).to eq User.find_by(login: :norbert)
  end

end
