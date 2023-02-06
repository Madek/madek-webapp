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

  it 'warns when closing window and lets user confirm' do

    #
    pending 'capyara issue, window closing not working'
    #

    open_permission_editable
    interact_with_page_so_we_dont_look_like_spammers

    # trying to leave the page by closing it:
    page.current_window.close
    accept_confirm(wait: 30)

    # NOTE: seems to be only way to expect closing, relies on weird behaviour:
    expect { page.windows.length }.to raise_error Errno::ECONNREFUSED

    # NOTE: we need to cleanup for cabybara bc we closed the window…
    begin; Capybara.current_session.driver.quit; rescue; 'ignore'; end
  end

end
