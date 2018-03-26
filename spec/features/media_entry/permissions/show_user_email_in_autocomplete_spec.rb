require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MediaEntryPermissionsShared

feature 'Resource: MediaEntry' do
  background do
    @user = User.find_by(login: 'normin')
    @entry = FactoryGirl.create(:media_entry_with_image_media_file,
                                responsible_user: @user)

    sign_in_as @user.login
  end

  it 'shows user email in search autocomplete' do
    user = FactoryGirl.create(:user, login: 'alice', email: 'user@example.com')

    open_permission_editable
    within('.ui-rights-body', text: 'Nutzer/innen') do
      input = find('input')
      input.click
      input.set(user.login)
      # input.click
      sleep 1
      results = find('.ui-autocomplete .ui-menu-item', text: user.email, wait: 10)
      expect(results).to be
      visit('about:blank')
      accept_confirm
    end
  end

end
