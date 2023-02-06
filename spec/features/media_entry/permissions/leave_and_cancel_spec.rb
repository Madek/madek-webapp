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
    interact_with_page_so_we_dont_look_like_spammers
    start_path = current_path_with_query

    # trying to leave the page with a link:
    find('header li a', text: I18n.t(:sitemap_my_archive)).click
    dismiss_confirm
    expect(current_path_with_query).to eq start_path

    # cleanup in any case
    visit '/'
    accept_confirm
  end

end
