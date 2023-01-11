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

  it 'warns when closing window and lets user cancel' do
    pending('This can not be tested with the current version of Capybara')
    # This scenario is about a user trying the close the window, the application should
    # bring up a confirm dialog then, which the user dismisses (cancels).
    # However capybara does not wait for the beforeunload handler and immediately ends
    # its session with the browser. So `dismiss_confirm` will throw. This is not fixable
    # on our side.
    # In addition, Capybara throws at `current_window.close`, with "Not allowed to close
    # the primary window". This could be worked around by opening a second window.
    # This spec is not very important, because the beforeunload handler as such is covered by
    # other specs.

    open_permission_editable
    interact_with_page_so_we_dont_look_like_spammers
    start_path = current_path_with_query

    # trying to leave the page by closing it:
    page.current_window.close
    dismiss_confirm
    expect(current_path_with_query).to eq start_path

    # cleanup in any case
    visit '/'
    accept_confirm
  end

end
