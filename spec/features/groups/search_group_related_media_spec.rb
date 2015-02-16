require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Search for group related media resources' do
  
  scenario 'Should find media sets related to a group, with appropriate permissions', browser: :headless do
    @current_user = sign_in_as 'adam'
    group = FactoryGirl.create :group
    media_set = FactoryGirl.create :media_set
    FactoryGirl.create :grouppermission, view: true, download: true, edit: false, media_resource: media_set, group: group
    media_set = FactoryGirl.create :media_set
    @group_permission = FactoryGirl.create :grouppermission, view: true, download: false, edit: false, media_resource: media_set, group: group
    visit '/app_admin/groups'
    find_input_with_name('filter[search_terms]').set(group.name)
    click_on_text 'Apply'
    within("tr##{group.name[0] + group.id}") do
      @count = find('.sets-count').text
    end
    visit media_resources_path(permission_presets: { ids: group.id, category: { view: true, download: false, manage: false, edit: false } }, type: 'sets')
    find('#user-action-button').click
    click_on_text 'In Admin-Modus wechseln'
    count = find('#resources_counter').text
    expect(count).to eq '1'
    expect(@count).to eq '2'
  end

  scenario 'Should find media entries related to a group, with appropriate permissions', browser: :headless do
    @current_user = sign_in_as 'adam'
    group = FactoryGirl.create :group
    media_entry = FactoryGirl.create :media_entry_with_image_media_file
    FactoryGirl.create :grouppermission, view: true, download: true, edit: false, media_resource: media_entry, group: group
    media_entry = FactoryGirl.create :media_entry_with_image_media_file
    @group_permission = FactoryGirl.create :grouppermission, view: true, download: false, edit: false, media_resource: media_entry, group: group
    visit '/app_admin/groups'
    find_input_with_name('filter[search_terms]').set(group.name)
    click_on_text 'Apply'
    within("tr##{group.name[0] + group.id}") do
      @count = find('.entries-count').text
    end
    visit media_resources_path(permission_presets: { ids: group.id, category: { view: true, download: false, manage: false, edit: false } }, type: 'media_entries')
    find('#user-action-button').click
    click_on_text 'In Admin-Modus wechseln'
    count = find('#resources_counter').text
    expect(count).to eq '1'
    expect(@count).to eq '2'
  end
end
