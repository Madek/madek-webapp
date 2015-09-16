require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry#show' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login

    # TODO: factories???
    @the_entry = '/entries/e157bedd-c2ba-41d8-8ece-82d73066a11e'
    visit @the_entry
  end

  it 'is rendered' do
    expect(page.status_code).to eq 200
  end

  it "tab: 'Entry'" do
    #  - title
    expect(page).to have_content 'Title Ausstellung Photo 1'
  end

  it "tab: 'Relations'" do
    click_on_tab 'Relations'
    # - parents
    expect(page).to have_content 'Ausstellungen'
    # - siblings
    expect(page).to have_content 'Ausstellung Gallerie Limatquai '
  end

  it "tab: 'More Data'" do
    click_on_tab 'More Data'
    # - Activity Log
    expect(page).to have_content 'import_date 20.04.2012'
    # - File Information
    expect(page).to have_content 'Filename berlin_wall_01.jpg'
  end

  it "tab: 'Permissions'" do
    # - privacy_status icon:
    permissions_tab = find('li.ui-tabs-item', text: 'Permissions')
    expect(permissions_tab.find('.icon-privacy-open')).to be

    click_on_tab 'Permissions'
    expect(page).to have_content 'Responsible user Normin Normalo'
    expect(page).to have_content \
      'Your permissions
      [:get_metadata_and_previews, :get_full_size, ' \
      ':edit_metadata, :edit_permissions]'
  end

end
