require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry - Permissions Tooltips' do
  background do
    @user = User.find_by(login: 'normin')
    @entry = FactoryBot.create(:media_entry_with_image_media_file,
                                responsible_user: @user)
  end

  scenario 'displays tooltip for API client permissions' do
    # Create an API client with permission descriptions
    api_client = create(:api_client, 
                        login: 'test_client',
                        permission_descriptions: { 'de' => 'Test API Client Description', 'en' => 'Test API Client Description' })
    
    # Add API client permission to the entry
    create(:media_entry_api_client_permission,
           media_entry: @entry,
           api_client: api_client,
           get_metadata_and_previews: true)
    
    sign_in_as @user.login
    visit permissions_media_entry_path(@entry)
    
    form = find('[name="ui-rights-management"]')
    row = subject_row(form, I18n.t(:permission_subject_title_apiapps))
    
    # Find the row containing the API client
    api_client_row = row.find('tbody tr', text: api_client.login)
    
    # Verify tooltip toggle icon is present
    expect(api_client_row).to have_css('.ui-rights-management__ttip-toggle')
    
    # Hover over the tooltip toggle to show the tooltip
    within(api_client_row) do
      find('.ui-rights-management__ttip-toggle').hover
    end
    
    # Verify tooltip content is displayed
    within '.tooltip' do
      expect(page).to have_content('Test API Client Description')
    end
  end

  scenario 'displays tooltip for public permissions' do
    # Set public permission description in app settings
    app_setting = AppSetting.first
    app_setting.update(permission_public_descriptions: { 'de' => 'Sichtbar für alle', 'en' => 'Visible for everyone' })
    
    # Set public permission on the entry
    @entry.update(get_metadata_and_previews: true)
    
    sign_in_as @user.login
    visit permissions_media_entry_path(@entry)
    
    form = find('[name="ui-rights-management"]')
    row = subject_row(form, I18n.t(:permission_subject_title_public))
    
    # Find the public permissions row
    public_row = row.find('tbody tr', text: I18n.t(:permission_subject_name_public))
    
    # Verify tooltip toggle icon is present
    expect(public_row).to have_css('.ui-rights-management__ttip-toggle')
    
    # Hover over the tooltip toggle to show the tooltip
    within(public_row) do
      find('.ui-rights-management__ttip-toggle').hover
    end
    
    # Verify tooltip content is displayed
    within '.tooltip' do
      expect(page).to have_content('Sichtbar für alle')
    end
  end

  scenario 'tooltips persist in edit mode' do
    # Create an API client with permission descriptions
    api_client = create(:api_client,
                        login: 'edit_client',
                        permission_descriptions: { 'de' => 'Edit Mode Tooltip', 'en' => 'Edit Mode Tooltip' })
    
    # Add API client permission to the entry
    create(:media_entry_api_client_permission,
           media_entry: @entry,
           api_client: api_client,
           get_metadata_and_previews: true)
    
    sign_in_as @user.login
    visit permissions_media_entry_path(@entry)
    
    form = find('[name="ui-rights-management"]')
    
    # Start editing
    form.click_on(I18n.t(:permissions_table_edit_btn))
    expect(current_path).to eq edit_permissions_media_entry_path(@entry)
    
    row = subject_row(form, I18n.t(:permission_subject_title_apiapps))
    
    # Find the row containing the API client
    api_client_row = row.find('tbody tr', text: api_client.login)
    
    # Verify tooltip toggle icon is still present in edit mode
    expect(api_client_row).to have_css('.ui-rights-management__ttip-toggle')
    
    # Hover over the tooltip toggle to show the tooltip
    within(api_client_row) do
      find('.ui-rights-management__ttip-toggle').hover
    end
    
    # Verify tooltip content is displayed
    within '.tooltip' do
      expect(page).to have_content('Edit Mode Tooltip')
    end
  end

end
