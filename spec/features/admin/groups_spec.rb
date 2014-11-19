require 'spec_helper_feature'
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

  def expect_first_row(group_name)
    expect(first('table tbody tr')).to have_content(group_name)
  end

  def expect_users_count(count)
    expect(first('.users-count').text.to_i).to eq(count)
  end

  def assign_users_to(originator, receiver)
    originator.users << User.where(login: %w{petra norbert karen})
    receiver.users << User.where(login: 'norbert')

    expect(originator.users.count).to eq(3)
    expect(receiver.users.count).to eq(1)
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

  def expect_permissions_for_receiver
    @receiver_permission.reload
    expect(@receiver_permission.view).to be true
    expect(@receiver_permission.edit).to be true
    expect{ @originator_permission.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
