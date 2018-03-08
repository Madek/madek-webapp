require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
include FavoriteHelper

# NOTE: this uses rack-test "browser" to make sure it can be viewed without js

feature 'Resource: MediaEntry' do
describe 'Action: show' do
  background do
    # TODO: factory
    @entry = MediaEntry.find 'e157bedd-c2ba-41d8-8ece-82d73066a11e'
  end

  context '(for public/no user logged in)' do

    it 'is rendered and shows title', browser: false do
      visit media_entry_path(@entry)
      expect(page.status_code).to eq 200
      expect(page.find('.ui-body-title')).to have_content 'Ausstellung Photo 1'
    end

    scenario "Tab: 'Permissions'. Not shown for public." do
      visit media_entry_path(@entry)
      expect(page).not_to have_content I18n.t(:media_entry_tab_permissions)
    end

    scenario "Tab: 'Temporary URLs'. Not shown for public." do
      visit media_entry_path(@entry)
      expect(page).not_to have_content 'Temporary URLs'
    end

    it 'does not display link to admin' do
      visit media_entry_path(@entry)

      within '.ui-body-title-actions .dropdown' do
        find('a').click
      end
      within '.dropdown.open' do
        expect(page).not_to have_link I18n.t(:resource_action_show_in_admin)
      end
    end

  end

  context '(for logged in user)' do

    background do
      @user = User.find_by(login: 'normin')
      sign_in_as @user.login
      visit media_entry_path(@entry)
    end

    it 'is rendered', browser: false do
      expect(page.status_code).to eq 200
    end

    scenario "Tab: 'Entry'. Shows Title" do
      #  - title
      expect(page.find('.ui-body-title')).to have_content 'Ausstellung Photo 1'
    end

    scenario "Tab: 'Relations'. Shows a parent and a sibling." do
      click_on_tab I18n.t(:media_entry_tab_relations)
      # - parents
      expect(page).to have_content 'Ausstellungen'
      # - siblings
      expect(page).to have_content 'Ausstellung Gallerie Limatquai '
    end

    scenario "Tab: 'Usage Data'. Shows import date and File Information" do
      click_on_tab I18n.t(:media_entry_tab_usage_data)
      # - Activity Log
      expect(page).to have_content I18n.t(:usage_data_import_at) + ' 20.04.2012'
      # - File Information
      expect(page).to have_content 'Filename berlin_wall_01.jpg'
    end

    scenario "Tab: 'More Data'. Shows meta key title" do
      click_on_tab I18n.t(:media_entry_tab_more_data)

      within('.ui-metadata-box .media-data') do
        expect(page).to have_selector('.media-data-title', text: 'Titel')
        expect(page).to have_selector('.media-data-content', text: @entry.title)
      end
    end

    scenario "Tab: 'More Data'. Vocabularies shown in configured order" do
      ['copyright:source', 'media_content:patron'].each do |mkid|
        create(:meta_datum_text, media_entry: @entry, meta_key_id: mkid)
      end

      visit media_entry_path(@entry)
      click_on_tab I18n.t(:media_entry_tab_more_data)

      within('.media-entry-metadata') do
        shown_voc_titles = all('.ui-metadata-box .title-l').map(&:text)
        ordered_voc_titles = @entry.meta_data.map(&:vocabulary).uniq
          .sort_by(&:position).map(&:label)
        expect(shown_voc_titles).to eq ordered_voc_titles
      end
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
        [I18n.t(:permission_name_get_metadata_and_previews),
         I18n.t(:permission_name_get_full_size),
         I18n.t(:permission_name_edit_metadata),
         I18n.t(:permission_name_edit_permissions)].join('')
    end

    it 'Favorite button is working when logged in.' do
      favorite_check_logged_in(@user, @entry)
    end

    it 'does not display link to admin' do
      visit media_entry_path(@entry)

      within '.ui-body-title-actions .dropdown' do
        find('a').click
      end
      within '.dropdown.open' do
        expect(page).not_to have_link I18n.t(:resource_action_show_in_admin)
      end
    end

  end

  context '(for logged in admin user)' do
    background do
      @user = User.find_by(login: 'adam')
      sign_in_as @user.login
      visit media_entry_path(@entry)
    end

    it 'displays link to admin' do
      visit media_entry_path(@entry)

      within '.ui-body-title-actions .dropdown' do
        find('a').click
      end
      within '.dropdown.open' do
        expect(page).to have_link(
          I18n.t(:resource_action_show_in_admin),
          href: admin_entry_path(@entry)
        )
      end
    end
  end

  it 'Favorite button is not visible for media entry whenn not logged in.' do
    visit media_entry_path(@entry)
    favorite_check_logged_out
  end

end
end
