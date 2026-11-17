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

  it 'warns when leaving edit form and lets user cancel' do
    open_permission_editable
    start_path = current_path_with_query

    # leaving the page is intercepted (canceling the prompt is up to the browser):
    expect(leave_warning_message).to eq I18n.t(:app_confirm_form_leave_msg)
    expect(current_path_with_query).to eq start_path
  end

end
