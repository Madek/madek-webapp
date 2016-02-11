require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

# NOTE: this uses rack-test "browser" to make sure it can be viewed without js

feature 'Resource: MediaEntry' do
describe 'Action: show (for logged in user)' do

  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login

    @the_entry = '/entries/e157bedd-c2ba-41d8-8ece-82d73066a11e'
    visit @the_entry
  end

  it 'is rendered' do
    expect(page.status_code).to eq 200
  end

  scenario "Tab: 'Entry'. Shows Title" do
    #  - title
    expect(page).to have_content 'Title Ausstellung Photo 1'
  end

  scenario "Tab: 'Relations'. Shows a parent and a sibling." do
    click_on_tab I18n.t(:media_entry_tab_relations)
    # - parents
    expect(page).to have_content 'Ausstellungen'
    # - siblings
    expect(page).to have_content 'Ausstellung Gallerie Limatquai '
  end

  scenario "Tab: 'More Data'. Shows import date and File Information" do
    click_on_tab I18n.t(:media_entry_tab_more_data)
    # - Activity Log
    expect(page).to have_content 'import_date 20.04.2012'
    # - File Information
    expect(page).to have_content 'Filename berlin_wall_01.jpg'
  end

  scenario "Tab: 'Permissions'. \
  Has 'privacy status' icon; shows permission summary for logged in user." do
    # - privacy_status icon:
    permissions_tab = find(
      'li.ui-tabs-item', text: I18n.t(:media_entry_tab_permissions))
    expect(permissions_tab.find('.icon-privacy-open')).to be

    click_on_tab I18n.t(:media_entry_tab_permissions)
    expect(page).to have_content 'Sie, Normin Normalo, haben'
    expect(page).to have_content \
      ['Betrachten',
       'Original exportieren & in PDF blättern',
       'Metadaten editieren & Inhalte zu Set hinzufügen',
       'Zugriffsberechtigungen ändern'].join('')
  end

end
end
