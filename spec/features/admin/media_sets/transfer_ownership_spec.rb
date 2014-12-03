require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Admin - Media Sets' do
  background { @current_user = sign_in_as 'adam' }

  scenario 'Sending request to change ownership with not checked any option', browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'akt'
    select_entry_from_autocomplete_list
    click_button 'Transfer'
    expect_notice_with_text 'Choose at least one of transfer option.'
  end

  scenario 'Changing ownership of a set and deleting all permissions for the current owner', browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'adam'
    select_entry_from_autocomplete_list
    check 'transfer_ownership'
    check 'delete_permissions'
    click_button 'Transfer'
    expect_media_set_to_have_new_owner
    expect_former_owner_not_to_have_any_permissions
  end

  scenario 'Changing ownership of a set without deleting permissions for the current owner', browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'adam'
    select_entry_from_autocomplete_list
    check 'transfer_ownership'
    click_button 'Transfer'
    expect_media_set_to_have_new_owner
    expect_former_owner_to_have_userpermissions
  end

  scenario "Changing ownership of set's children media entries
    and deleting all permissions for the current owner", browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions(true)
    expect_media_set_to_have_children
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'adam'
    select_entry_from_autocomplete_list
    check 'transfer_children_media_entries'
    check 'delete_permissions_for_media_entries'
    click_button 'Transfer'
    expect_media_set_not_to_have_new_owner
    expect_former_owner_not_to_have_any_permissions_for_children_resources('MediaEntry')
  end

  scenario "Changing ownership of set's children media entries
    without deleting permissions for the current owner", browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions(true)
    expect_media_set_to_have_children
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'adam'
    select_entry_from_autocomplete_list
    check 'transfer_children_media_entries'
    click_button 'Transfer'
    expect_media_set_not_to_have_new_owner
    expect_former_owner_to_have_userpermissions_for_children_resources('MediaEntry')
  end

  scenario "Changing ownership of set's children sets
    and deleting all permissions for the current owner", browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions(true)
    create_children_sets_with_userpermissions
    expect_media_set_to_have_children
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'adam'
    select_entry_from_autocomplete_list
    check 'transfer_children_sets'
    check 'delete_permissions_for_sets'
    click_button 'Transfer'
    expect_media_set_not_to_have_new_owner
    expect_former_owner_not_to_have_any_permissions_for_children_resources('MediaSet')
  end

  scenario "Changing ownership of set's children sets
    without deleting permissions for the current owner", browser: :firefox do
    find_not_owned_media_set_with_owner_userpermissions(true)
    create_children_sets_with_userpermissions
    expect_media_set_to_have_children
    visit app_admin_media_set_path(@media_set)
    click_link 'Change Ownership of set and its children'
    fill_in '[query]', with: 'adam'
    select_entry_from_autocomplete_list
    check 'transfer_children_sets'
    click_button 'Transfer'
    expect_media_set_not_to_have_new_owner
    expect_former_owner_to_have_userpermissions_for_children_resources('MediaSet')
  end

  def create_children_sets_with_userpermissions
    child_set = FactoryGirl.create(:media_set, user: @media_set.user)
    @media_set.child_media_resources << child_set
    expect(@media_set.child_media_resources.where(type: 'MediaSet').count).to be == 1
    child_set.userpermissions.create(
      user: @former_owner,
      download: true,
      edit: true,
      manage: true,
      view: true
    )
  end

  def expect_former_owner_not_to_have_any_permissions
    expect {
      Userpermission.find_by!(user_id: @former_owner.id, media_resource_id: @media_set.id)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def expect_former_owner_not_to_have_any_permissions_for_children_resources(type)
    child_resources = @media_set.child_media_resources.where(type: type)
    child_resources.each do |child|
      expect {
        Userpermission.find_by!(user_id: @former_owner.id, media_resource_id: child.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  def expect_former_owner_to_have_userpermissions
    userpermissions = Userpermission.find_by!(user_id: @former_owner.id, media_resource_id: @media_set.id)
    expect(userpermissions.download).to be true
    expect(userpermissions.edit).to be true
    expect(userpermissions.manage).to be true
    expect(userpermissions.view).to be true
  end

  def expect_former_owner_to_have_userpermissions_for_children_resources(type)
    child_resources = @media_set.child_media_resources.where(type: type)
    child_resources.each do |child|
      userpermissions = Userpermission.find_by!(user_id: @former_owner.id, media_resource_id: child.id)
      expect(userpermissions.download).to be true
      expect(userpermissions.edit).to be true
      expect(userpermissions.manage).to be true
      expect(userpermissions.view).to be true
    end
  end

  def expect_media_set_not_to_have_new_owner
    expect(@media_set.reload.user_id).to be == @former_owner.id
  end

  def expect_media_set_to_have_children
    expect(@media_set.child_media_resources.count).to be > 0
  end

  def expect_media_set_to_have_new_owner
    expect(@media_set.reload.user_id).to be== @current_user.id
  end

  def expect_notice_with_text(text)
    expect(page).to have_selector('.alert-info', text: text)
  end

  def find_not_owned_media_set_with_owner_userpermissions(userpermissions_for_children = false)
    @media_set = MediaSet.where.not(user_id: @current_user.id).first
    @former_owner = @media_set.user
    @media_set.userpermissions.create(
      user: @former_owner,
      download: true,
      edit: true,
      manage: true,
      view: true
    )
    expect {
      Userpermission.find_by!(user_id: @former_owner.id, media_resource_id: @media_set.id)
    }.not_to raise_error

    if userpermissions_for_children
      @media_set.child_media_resources.each do |child|
        child.userpermissions.create(
          user: @former_owner,
          download: true,
          edit: true,
          manage: true,
          view: true
        )

        expect {
          Userpermission.find_by!(user_id: @former_owner.id, media_resource_id: child.id)
        }.not_to raise_error
      end
    end
  end

  def select_entry_from_autocomplete_list(index_or_text = 0, input_name = '[query]')
    page.execute_script %Q{ $('[name="#{input_name}"]').trigger('keydown') }
    selector = if index_or_text.is_a?(Integer)
      %Q{ ul.ui-autocomplete li.ui-menu-item:eq(#{index_or_text}) }
    else
      %Q{ ul.ui-autocomplete li.ui-menu-item:contains(\'#{index_or_text}\') }
    end

    expect(page).to have_selector('ul.ui-autocomplete li.ui-menu-item')
    page.execute_script %Q{ $("#{selector}").trigger('mouseenter').click() }

    page.execute_script %Q{ $('.ui-menu-item:first').trigger('mouseenter').click() }
  end
end
