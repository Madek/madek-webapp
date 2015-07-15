require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Workgroups" do

  background do
    @current_user = sign_in_as "normin"
  end

  feature "Create a new group", browser: :firefox do
    it "is OK with new name" do
      name = Faker::Name.last_name
      visit my_groups_path

      create_group(name)
      
      assert_modal_not_visible
      expect(@current_user.groups.find_by_name(name)).to be
    end
    it "FAILS when name already exists" do
      name = Faker::Name.last_name
      visit my_groups_path

      create_group(name)
      assert_modal_not_visible

      create_group(name)
      assert_error_alert
    end
  end

  scenario "Requiring name during group creation", browser: :firefox do

    visit my_groups_path

    create_new_group_with_context_primary_action

    click_primary_action_of_modal

    assert_error_alert

  end

  scenario "Edit group members", browser: :firefox do

    visit my_groups_path

    edit_one_group

    add_new_member_to_the_group

    delete_existing_member_from_the_group

    click_primary_action_of_modal

    assert_modal_not_visible
    expect(@group.users.find(@added_user.id)).to be
    expect{@group.users.find(@removed_user.id)}.to raise_error

  end

  scenario "Delete a group", browser: :firefox do

    visit my_groups_path

    edit_one_group

    remove_all_members_of_specific_group_except_current_user

    delete_group

    expect{ Group.find @group.id }.to raise_error

  end

  scenario "Error during group deletion", browser: :firefox do

    visit my_groups_path

    delete_group_with_members_current_user_and_others

    assert_error_alert

    expect{ Group.find @group.id }.not_to raise_error

  end

  scenario "Successfully edit group name", browser: :firefox do

    visit my_groups_path

    edit_one_group

    change_group_name

    click_primary_action_of_modal
    wait_for_ajax
    assert_modal_not_visible

    expect(page).to have_selector("tr[data-id='#{@group.id}'] .ui-workgroup-name a", text: @name)
    expect(@group.reload.name).to eq @name

  end

  scenario "Error providing empty group name during edit", browser: :firefox do

    visit my_groups_path

    edit_one_group

    # empty group name
    find('.modal.ui-shown #show-edit-name').click
    find("input#group-name").set ""

    click_primary_action_of_modal

    assert_error_alert

    expect(@group.reload.name).not_to eq @name

  end

  def create_new_group_with_context_primary_action
    find(".ui-body-title-actions .primary-button").click
    assert_modal_visible
  end

  def create_group(name)
    create_new_group_with_context_primary_action
    find("input[name='name']").set name
    click_primary_action_of_modal
  end

  def edit_one_group
    @group = @current_user.groups.first
    find(".ui-workgroups tr[data-id='#{@group.id}'] .button.edit-workgroup").click
    assert_modal_visible
  end

  def add_new_member_to_the_group
    @added_user = User.where(User.arel_table[:id].not_eq(@current_user.id)).where(User.arel_table[:id].not_in(@group.users.map(&:id))).first
    find("input#add-user").set @added_user.to_s
    find("ul.ui-autocomplete li a", text: @added_user.to_s).click
  end

  def delete_existing_member_from_the_group
    @removed_user = User.where(User.arel_table[:id].not_eq(@current_user.id)).where(User.arel_table[:id].in(@group.users.map(&:id))).first
    find("#user-list tr", :text => @removed_user.to_s).find(".button[data-remove-user]").click
    expect(page).not_to have_selector("#user-list tr", :text => @removed_user.to_s)
  end

  def remove_all_members_of_specific_group_except_current_user
    all_users_expect_myself = @group.users.where(User.arel_table[:id].not_eq(@current_user.id))
    all_users_expect_myself.each do |user|
      find("#user-list tr", :text => user.to_s).find(".button[data-remove-user]").click
      expect(page).not_to have_selector("#user-list tr", :text => user.to_s)
    end
    find("#user-list tr") # exactly one
    click_primary_action_of_modal
  end

  def delete_group
    find(".ui-workgroups tr[data-id='#{@group.id}'] .button.delete-workgroup").click
    assert_modal_visible
    click_primary_action_of_modal
    assert_modal_not_visible
  end

  def delete_group_with_members_current_user_and_others
    @group = @current_user.groups.joins("INNER JOIN groups_users AS gu2 ON groups.id = gu2.group_id").group("groups.id, gu2.group_id").having("count(gu2.group_id) > 1").first
    find(".ui-workgroups tr[data-id='#{@group.id}'] .button.delete-workgroup").click
  end

  def change_group_name
    find('.modal.ui-shown #show-edit-name').click
    @name = Faker::Name.last_name
    within '.ui-modal' do
      fill_in 'group-name', with: @name
    end
  end

end
