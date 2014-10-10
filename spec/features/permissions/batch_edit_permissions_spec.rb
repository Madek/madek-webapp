require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'permissions', 'shared.rb')

feature 'Edit the permissions through batch-edit' do
  include Features::Permissions::Shared

  background do
    @current_user = sign_in_as 'normin'
    find_owned_resource_with_no_other_permissions(1)

    add_user_permission_to_resource 'view', 'liselotte', 1
    add_user_permission_to_resource 'download', 'liselotte', 1

    add_user_permission_to_resource 'view', 'petra', 1
    add_user_permission_to_resource 'edit', 'petra', 1
    add_user_permission_to_resource 'manage', 'petra', 1

    add_user_permission_to_resource 'view', 'karen', 1

    find_owned_resource_with_no_other_permissions(2)

    add_user_permission_to_resource 'view', 'liselotte', 2
    add_user_permission_to_resource 'download', 'liselotte', 2
    add_user_permission_to_resource 'manage', 'liselotte', 2

    add_user_permission_to_resource 'view', 'petra', 2
    add_user_permission_to_resource 'edit', 'petra', 2
    add_user_permission_to_resource 'download', 'petra', 2

    add_resource_to_clipboard 1
    add_resource_to_clipboard 2
    visit '/'
    click_on_text 'Zwischenablage'
    expect(page).to have_css('.ui-clipboard.ui-open')
    expect_resource_in_clipboard 1
    expect_resource_in_clipboard 2
    click_link 'clipboard-actions'
    click_link 'view-clipboard-permissions'
    click_link 'edit-permissions'
    wait_for_ajax
    expect(page).to have_css('form#ui-rights-management')
  end

  after(:each) do
    page.execute_script('sessionStorage.clear()')
  end

  scenario 'Looking at the permission page', browser: :firefox do
    find('.ui-resources-selection .ui-resources-media', visible: true)
    find('.ui-resources-selection .ui-resources-table', visible: false)
  end

  scenario 'Looking at the permission properties', browser: :firefox do
    expect_checked_permission_for 'liselotte', 'view'
    expect_not_checked_permission_for 'liselotte', 'edit'
    expect_checked_permission_for 'liselotte', 'download'
    expect_mixed_permission_for 'liselotte', 'manage'

    expect_checked_permission_for 'petra', 'view'
    expect_checked_permission_for 'petra', 'edit'
    expect_mixed_permission_for 'petra', 'download'
    expect_mixed_permission_for 'petra', 'manage'

    expect_mixed_permission_for 'karen', 'view'
    expect_not_checked_permission_for 'karen', 'edit'
    expect_not_checked_permission_for 'karen', 'download'
    expect_not_checked_permission_for 'karen', 'manage'
  end

  scenario 'Saving without changing anything', browser: :firefox do
    click_on_text 'Speichern'

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', true, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', false, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', false, 2
  end

  scenario 'Disabling a manage permission', browser: :firefox do
    click_on_permission_until_it_is 'false', 'manage', 'petra'
    click_on_text 'Speichern'
    wait_for_ajax

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', false, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', false, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', false, 2
  end

  scenario 'Enabling a manage permission', browser: :firefox do
    click_on_permission_until_it_is 'true', 'manage', 'petra'
    click_on_text 'Speichern'
    wait_for_ajax

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', true, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', false, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', true, 2
  end

  scenario 'Keeping mixed state', browser: :firefox do
    click_on_permission_until_it_is 'mixed', 'manage', 'petra'
    click_on_text 'Speichern'
    wait_for_ajax

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', true, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', false, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', false, 2
  end

  scenario 'Creating a new user permission', browser: :firefox do
    click_on_permission_until_it_is 'true', 'manage', 'karen'
    click_on_text 'Speichern'
    wait_for_ajax

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', true, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', true, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', false, 2

    expect_resource_to_have_userpermission 'karen', 'manage', true, 2
  end

  scenario 'Changing public view permission does not change userpermission', browser: :firefox do
    check_public_permission 'view'
    click_on_text 'Speichern'
    wait_for_ajax

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', true, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', false, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', false, 2
  end

  scenario 'Changing public download permission does not change userpermission', browser: :firefox do
    check_public_permission 'download'
    click_on_text 'Speichern'
    wait_for_ajax

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 1
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 1
    expect_resource_to_have_userpermission 'liselotte', 'manage', false, 1

    expect_resource_to_have_userpermission 'petra', 'view', true, 1
    expect_resource_to_have_userpermission 'petra', 'edit', true, 1
    expect_resource_to_have_userpermission 'petra', 'download', false, 1
    expect_resource_to_have_userpermission 'petra', 'manage', true, 1

    expect_resource_to_have_userpermission 'karen', 'view', true, 1
    expect_resource_to_have_userpermission 'karen', 'edit', false, 1
    expect_resource_to_have_userpermission 'karen', 'download', false, 1
    expect_resource_to_have_userpermission 'karen', 'manage', false, 1

    expect_resource_to_have_userpermission 'liselotte', 'view', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'edit', false, 2
    expect_resource_to_have_userpermission 'liselotte', 'download', true, 2
    expect_resource_to_have_userpermission 'liselotte', 'manage', true, 2

    expect_resource_to_have_userpermission 'petra', 'view', true, 2
    expect_resource_to_have_userpermission 'petra', 'edit', true, 2
    expect_resource_to_have_userpermission 'petra', 'download', true, 2
    expect_resource_to_have_userpermission 'petra', 'manage', false, 2
  end

  def add_resource_to_clipboard(n)
    id = @resources[n].id
    visit "/media_resources/#{id}"
    find("a[data-clipboard-toggle]").click
    wait_for_ajax
    expect(page).not_to have_css(".ui-clipboard li.ui-resource[data-id='#{id}']")
  end

  def check_public_permission(permission)
    within '.ui-rights-management-public' do
      check permission.to_s
    end
  end

  def click_on_permission_until_it_is(value, permission, login)
    user = User.find_by!(login: login)
    td_element = find("tr[data-name='#{user.to_s}'] td.ui-rights-check.#{permission}")
    input_element = td_element.find("input[name='#{permission}']")

    input_element.instance_eval do
      def mixed?
        value == 'mixed'
      end
    end

    begin
      input_element.click
      done =
        case value
        when 'false'
          not input_element.mixed? and not input_element.checked?
        when 'true'
          not input_element.mixed? and input_element.checked?
        when 'mixed'
          input_element.mixed?
        else
          raise 'you should never got here'
        end
    end while not done
  end

  def expect_resource_in_clipboard(n)
    resource = @resources[n]
    expect(find('.ui-clipboard-counter')).to have_content("#{n}") if n > 1
    expect(page).to have_css(".ui-clipboard .ui-resource[data-id='#{resource.id}']")
  end

  def expect_resource_to_have_userpermission(login, permission, state, n)
    media_resource = @resources[n]
    user = User.find_by!(login: login)
    userpermission = Userpermission.where(user_id: user.id, media_resource_id: media_resource.id).first
    expect(userpermission[permission]).to be state
  end

  def find_owned_resource_with_no_other_permissions(n)
    @resources ||= []
    @resources[n] = @current_user.media_resources[n]
    @resources[n].userpermissions.clear
    @resources[n].grouppermissions.clear
    @resources[n].update_attributes(
      view: false,
      edit: false,
      manage: false,
      download: false
    )
  end
end
