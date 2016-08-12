require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

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

private

def open_permission_editable
  visit permissions_media_entry_path(@entry)
  @node_form = find('[name="ui-rights-management"]')

  @node_people = subject_row(@node_form, I18n.t(:permission_subject_title_users))
  @node_groups = subject_row(@node_form, I18n.t(:permission_subject_title_groups))

  expect(subject_items(@node_people).length).to be 0
  expect(subject_items(@node_groups).length).to be 0
  # this is hidden on show when empty:
  expect(subject_row(@node_form, I18n.t(:permission_subject_title_apiapps)))
    .to be nil

  @node_form.click_on(I18n.t(:permissions_table_edit_btn))

  # router works:
  expect(current_path).to eq edit_permissions_media_entry_path(@entry)

  # now its visible:
  @node_apiapps = subject_row(
    @node_form, I18n.t(:permission_subject_title_apiapps))
  expect(subject_items(@node_apiapps).length).to be 0
end

def permission_types
  %w(
    get_metadata_and_previews
    get_full_size
    edit_metadata
    edit_permissions
  )
end

def subject_row(form, title)
  header = form.first('table thead', text: title)
  header.find(:xpath, '../../..') if header
end

def subject_items(node)
  node.all('tbody tr')
end

def add_subject_with_permission(node, name, permission_name)
  autocomplete_and_choose_first(node, name)
  node.find('tbody tr', text: name)
    .find("[name='#{permission_name}']")
    .click
end
