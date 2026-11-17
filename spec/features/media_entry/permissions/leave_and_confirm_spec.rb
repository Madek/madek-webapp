require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry' do
  background do
    @user = User.find_by(login: 'normin')
    @entry = FactoryBot.create(:media_entry_with_image_media_file,
                                responsible_user: @user)

    sign_in_as @user.login
  end

  it 'warns when leaving edit form and lets user confirm' do
    open_permission_editable
    expect(leave_warning_message).to eq I18n.t(:app_confirm_form_leave_msg)

    # leaving the page with a link (the browser auto-accepts the prompt):
    find('header li a', text: I18n.t(:sitemap_my_archive)).click
    wait_until { current_path == my_dashboard_path }
  end

end
