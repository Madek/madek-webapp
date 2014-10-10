require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Groups' do
  background { sign_in_as 'adam' }

  scenario 'Deleting a group containing users' do
    visit '/app_admin/groups'

    select 'Amount of users', from: 'sort_by'
    click_button 'Apply'

    expect_first_row 'ZHdK'
    expect_users_count(4)
    first('a', text: 'Delete').click

    expect(page).to have_css('.alert-danger', text: 'The group contains users and cannot be deleted.')
    expect_first_row 'ZHdK'
    expect_users_count(4)
  end

  scenario 'Deleting a group with no users' do
    visit '/app_admin/groups'

    expect_first_row 'Administrative Modulverantwortliche Evento'
    expect_users_count(0)
    first('a', text: 'Delete').click

    expect(page).to have_css('.alert-success', text: 'The group has been deleted.')
    expect(page).not_to have_content('Administrative Modulverantwortliche Evento')
  end

  scenario 'Merging an institutional group to another one' do
    originator, receiver = Group.departments.limit(2).to_a

    assign_users_to(originator, receiver)
    create_common_permission(originator, receiver)

    visit "/app_admin/groups/#{originator.id}"
    click_link 'Merge to'
    fill_in 'id_receiver', with: "#{receiver.id} "
    click_button 'Merge'

    expect(page).to have_css('.alert-success')
    expect(originator.users.count).to eq(0)
    expect(receiver.users.count).to eq(3)
    expect_permissions_for_receiver
  end

  scenario 'Merging an institutional group to an ordinary group' do
    institutional_group = Group.departments.first
    group = Group.where(type: 'Group').first

    visit app_admin_group_path(institutional_group)
    click_link 'Merge to'
    fill_in 'id_receiver', with: "#{group.id} "
    click_button 'Merge'

    expect(page).to have_css('.alert-danger')
  end

  scenario 'Deleting groups', browser: :firefox do
    visit '/app_admin/groups'
    filter_groups_with_term('MIZ-Archiv')

    expect(page).to have_css("table tbody tr", text: "MIZ-Archiv")
    click_link "Details"

    expect(page).to have_css("a", text: "Delete")

    accept_alert do
      click_link "Delete"
    end

    assert_partial_url_path '/app_admin/groups'
    assert_success_message

    filter_groups_with_term("MIZ-Archiv")
    expect(page).not_to have_css("table tbody tr", text: "MIZ-Archiv")
  end

  scenario 'Adding an user to a group', browser: :firefox do
    visit '/app_admin/groups'

    click_link 'Details', match: :first
    initial_count = count_users
    click_link "Add user"

    expect(find("button[type='submit']")[:disabled]).to eq "true"
    expect(find("input[name='[user_id]']", visible: false).value).to eq ""

    fill_in "[query]", with: "nor"
    select_entry_from_autocomplete_list

    expect(find("input[name='[user_id]']", visible: false).value).not_to eq ""
    expect(find("button[type='submit']")[:disabled]).to be_nil

    click_button "Add user"

    expect(page).to have_css(".alert-success")
    expect(count_users).to eq(initial_count + 1)
  end

  scenario 'Adding user to a group by login', browser: :firefox do
    visit '/app_admin/groups'

    click_link 'Details', match: :first
    expect(page).not_to have_content("norbert")

    click_link "Add user"
    fill_in "[query]", with: "[norbert]"
    click_button "Add user"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("norbert")
  end

  scenario 'Adding duplicated user to a group', browser: :firefox do
    visit '/app_admin/groups'

    filter_groups_with_term('')
    click_link 'Details', match: :first
    click_link "Add user"
    fill_in "[query]", with: "nor"
    select_entry_from_autocomplete_list
    click_button "Add user"

    expect(page).to have_css(".alert-danger", text: "The user normin already belongs to this group.")
  end

  scenario 'Removing user from a group' do
    visit '/app_admin/groups'

    filter_groups_with_term('')
    click_link 'Details', match: :first
    initial_count = count_users
    click_link 'Remove from group', match: :first

    expect(page).to have_css(".alert-success")
    expect(all(".group-users tbody tr").count).to eq(initial_count - 1)
  end

  scenario 'Listing all groups with their types' do
    visit '/app_admin/groups'

    select "Group", from: "type"
    click_button "Apply"

    expect(page).to have_css("th", text: "Type")
    expect(all("table tbody tr", text: "Group").count).to eq(all("table tbody tr").count)

    select "InstitutionalGroup", from: "type"
    click_button "Apply"

    expect(all("table tbody tr", text: "InstitutionalGroup").count).to eq(all("table tbody tr").count)
  end

  scenario 'Filtering groups by a search term' do
    visit '/app_admin/groups'

    fill_in "filter[search_terms]", with: "admin"
    click_button "Apply"

    all('table tbody tr').each do |row|
      expect(row.text).to match(/admin/i)
    end

    fill_in "filter[search_terms]", with: " admin   "
    click_button "Apply"

    all('table tbody tr').each do |row|
      expect(row.text).to match(/admin/i)
    end
    expect(find("input[name='filter[search_terms]']")[:value]).to eq("admin")
  end

  scenario 'Filtering groups by their types' do
    visit '/app_admin/groups'
    expect(find_field('type')[:value]).to eq("all")

    select "Group", from: "type"
    click_button "Apply"

    all('table tbody tr').each do |row|
      expect(row).to have_content("Group")
    end
    expect(find_field("type")[:value]).to eq("group")

    select "InstitutionalGroup", from: "type"
    click_button "Apply"

    all('table tbody tr').each do |row|
      expect(row).to have_content("InstitutionalGroup")
    end
    expect(find_field("type")[:value]).to eq("institutional_group")
  end

  scenario 'Creating a new group' do
    visit '/app_admin/groups'

    click_link "New group"
    fill_in "group[name]", with: "AWESOME GROUP"
    click_button "Submit"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("AWESOME GROUP")
  end

  scenario 'Editing a group' do
    visit '/app_admin/groups'

    select "Group", from: "type"
    click_button "Apply"
    all("a", text: "Edit")[1].click
    fill_in "group[name]", with: "AWESOME GROUP"
    click_button "Submit"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("AWESOME GROUP")
  end

  scenario 'Editing an institutional group' do
    visit '/app_admin/groups'

    select "InstitutionalGroup", from: "type"
    click_button "Apply"
    all("a", text: "Edit")[1].click
    fill_in "institutional_group[name]", with: "AWESOME INSTITUTIONAL GROUP"
    click_button "Submit"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("AWESOME INSTITUTIONAL GROUP")
  end

  def assign_users_to(originator, receiver)
    originator.users << User.where(login: %w{petra norbert karen})
    receiver.users << User.where(login: 'norbert')

    expect(originator.users.count).to eq(3)
    expect(receiver.users.count).to eq(1)
  end

  def count_users
    all('.group-users tbody tr').count
  end

  def create_common_permission(originator, receiver)
    @originator_permission = FactoryGirl.create(:grouppermission, view: true, edit: true, group: originator)

    attributes = @originator_permission.attributes.clone
    attributes.delete('id')
    attributes['group_id'] = receiver.id
    attributes['view'] = false
    attributes['edit'] = false
    @receiver_permission = Grouppermission.create!(attributes)

    expect(@receiver_permission.media_resource_id).to eq(@originator_permission.media_resource_id)
  end

  def expect_first_row(group_name)
    expect(first('table tbody tr')).to have_content(group_name)
  end

  def expect_permissions_for_receiver
    @receiver_permission.reload
    expect(@receiver_permission.view).to be true
    expect(@receiver_permission.edit).to be true
    expect{ @originator_permission.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  def expect_users_count(count)
    expect(first('.users-count').text.to_i).to eq(count)
  end

  def filter_groups_with_term(term)
    fill_in "filter[search_terms]", with: term
    select "Group", from: "type"
    click_button "Apply"
  end
end
