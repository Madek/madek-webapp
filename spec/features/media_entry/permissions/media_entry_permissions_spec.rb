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

    sign_in_as @user.login
  end

  scenario 'edit permissions' do

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

  scenario 'weaker permissions are set by higher ones' do

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

end
