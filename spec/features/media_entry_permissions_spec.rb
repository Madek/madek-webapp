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

  scenario 'edit permissions JS', browser: :firefox do

    test_perm = 'get_metadata_and_previews'
    other_perm = 'get_full_size'

    visit permissions_media_entry_path(@entry)
    form = find('[name="ui-rights-management"]')

    people = subject_row(form, 'Personen')
    groups = subject_row(form, 'Gruppen')

    expect(subject_items(people).length).to be 0
    expect(subject_items(groups).length).to be 0
    # this is hidden on show when empty:
    expect(subject_row(form, 'API-Applikationen')).to be nil

    form.click_on('Bearbeiten')

    # router works:
    expect(current_path).to eq edit_permissions_media_entry_path(@entry)

    # now its visible:
    apiapps = subject_row(form, 'API-Applikationen')
    expect(subject_items(apiapps).length).to be 0

    add_subject_with_permission(people, 'Norbert', test_perm)
    add_subject_with_permission(groups, 'Diplomarbeitsg', test_perm)
    add_subject_with_permission(apiapps, 'fancy', test_perm)

    form.click_on('Speichern')
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

end

private

def subject_row(form, title)
  header = form.first('table thead span', text: title)
  header.find(:xpath, '../../../../..') if header
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

def autocomplete_and_choose_first(node, text)
  unless Capybara.javascript_driver == :selenium
    throw 'Autocomplete is only supported in Selenium!'
  end
  ac = node.find('.ui-autocomplete-holder')
  input = ac.find('input')
  input.click
  input.native.send_keys(text)
  menu = ac.find('.ui-autocomplete.ui-menu')
  menu.first('.ui-menu-item').click
end
