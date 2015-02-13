require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin Groups' do
  background do
    @admin_user = create :admin_user, password: 'password'
    sign_in_as @admin_user.login
  end

  scenario 'Filtering/sorting groups by name' do
    visit '/admin/groups'
    fill_in 'search_terms', with: 'zhdk'
    click_button 'Apply'
    names = all('table tbody tr').map do |tr|
      expect(tr.find('td:first').text.downcase).to have_content 'zhdk'
    end
    expect(find_field('search_terms')[:value]).to eq 'zhdk'
    expect(names).to eq names.sort
  end

  scenario 'Filtering/sorting groups by text search ranking' do
    visit '/admin/groups'
    fill_in 'search_terms', with: 'zhdk'
    select 'Text search ranking', from: 'sort_by'
    click_button 'Apply'
    names = all('table tbody tr').map do |tr|
      expect(tr.find('td:first').text.downcase).to have_content 'zhdk'
    end
    expect(find_field('search_terms')[:value]).to eq 'zhdk'
    expect(find_field('sort_by')[:value]).to eq 'text_rank'
    expect(names).to eq names.sort
  end

  scenario 'Filtering/sorting groups by trigram search ranking' do
    visit '/admin/groups'
    fill_in 'search_terms', with: 'zhdk'
    select 'Trigram search ranking', from: 'sort_by'
    click_button 'Apply'
    names = all('table tbody tr').map do |tr|
      tr.all('td')[3].text
    end
    expect(find_field('search_terms')[:value]).to eq 'zhdk'
    expect(find_field('sort_by')[:value]).to eq 'trgm_rank'
    expect(names).to eq names.sort!
  end

  scenario 'Filtering groups by type' do
    visit '/admin/groups'
    select 'Group', from: 'type'
    click_button 'Apply'
    all('table tbody tr').each do |tr|
      expect(tr.all('td')[2].text).to eq 'Group'
    end
    expect(find_field('type')[:value]).to eq 'group'
  end

  scenario 'Editing a group' do
    @group = create :group
    visit admin_group_path(@group)
    click_link('Edit')
    fill_in 'group[name]', with: 'AWESOME GROUP'
    click_button 'Save'
    expect(page).to have_css('.alert-success')
    expect(page).to have_content('AWESOME GROUP')
  end

  scenario 'Creating a new group' do
    visit '/admin/groups'
    click_link('New group')
    fill_in 'group[name]', with: ''
    click_button 'Save'
    expect(page).to have_css('.alert-danger')
    fill_in 'group[name]', with: 'NEW AWESOME GROUP'
    click_button 'Save'
    expect(page).to have_css('.alert-success')
    expect(page).to have_content('NEW AWESOME GROUP')
  end

  scenario 'Deleting a group with users' do
    @group = create :group, :with_user
    visit admin_group_path(@group)
    click_link 'Delete'
    expect(page).to have_css('.alert-danger')
  end

  scenario 'Deleting a group without users' do
    @group = create :group
    visit admin_group_path(@group)
    click_link 'Delete'
    expect(page).to have_css('.alert-success')
  end

  scenario 'Adding a user to a group' do
    @group = create :group
    visit admin_group_path(@group)
    expect(page).to have_no_content('adam')
    click_link 'Add user'
    select 'Admin, Adam [adam]', from: 'user_id'
    click_button 'Add user'
    expect(page).to have_css('.alert-success')
    expect(page).to have_content('adam')
    expect(group_user_count).to eq 1
  end

  scenario 'Removing a user from a group' do
    @group = create :group, :with_user
    visit admin_group_path(@group)
    expect(group_user_count).to eq 1
    click_link 'Remove from group'
    expect(page).to have_css('.alert-success')
    expect(group_user_count).to eq 0
  end

  scenario 'Filtering users belonging to a group' do
    @group = create :group, :with_user
    @group.users << create(:user, login: 'test')
    visit admin_group_path(@group)
    expect(group_user_count).to eq 2
    fill_in '_fuzzy_search', with: 'test'
    click_button 'Filter'
    expect(group_user_count).to eq 1
    expect(find('table#group-users')).to have_content('test')
  end

  scenario 'Merging institutional group to regular group' do
    @merge_to = create :group
    @to_merge = Group.departments.first
    visit admin_group_path(@to_merge)
    click_link 'Merge to'
    fill_in 'id_receiver', with: @merge_to.id
    click_button 'Merge'
    expect(page).to have_css('.alert-danger')
  end

  scenario 'Merging institutional groups' do
    @merge_to = Group.departments.last
    @to_merge = Group.departments.first
    @to_merge.users << create(:user)
    visit admin_group_path(@merge_to)
    expect(group_user_count).to eq 0
    visit admin_group_path(@to_merge)
    expect(group_user_count).to eq 1
    click_link 'Merge to'
    fill_in 'id_receiver', with: @merge_to.id
    click_button 'Merge'
    expect(page).to have_css('.alert-success')
    visit admin_group_path(@merge_to)
    expect(group_user_count).to eq 1
  end

  def group_user_count
    all('table#group-users tbody tr').count
  end
end
