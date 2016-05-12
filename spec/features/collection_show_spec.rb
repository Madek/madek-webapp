require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/favorite_helper_spec'
require_relative 'shared/basic_data_helper_spec'
require_relative 'shared/ui_helpers_spec'
include UIHelpers
include FavoriteHelper
include BasicDataHelper

feature 'Resource: Collections' do
  def prepare_data
    prepare_user
    @collection = create_collection('Test Collection')
  end

  def open_collection
    login
    visit collection_path(@collection)
  end

  def prepare_and_open_collection
    prepare_data
    open_collection
  end

  describe 'Action: show' do
    it 'is rendered' do
      prepare_and_open_collection
      expect(page.status_code).to eq 200
    end

    scenario 'Tab: Main' do
      prepare_and_open_collection
      expect(page).to have_content @collection.title
      name = @user.person.first_name + ' ' + @user.person.last_name
      expect(page).to have_content name
    end

    scenario 'Tab: Relations' do
      prepare_data
      @parent = create_collection('Parent Collection')
      @sibling = create_collection('Sibling Collection')
      @collection.parent_collections << @parent
      @sibling.parent_collections << @parent
      open_collection
      click_on_tab I18n.t(:media_entry_tab_relations)
      expect(page).to have_content I18n.t(:relations_parents_title)
      expect(page).to have_content I18n.t(:relations_siblings_title)
      expect(page).to have_content @parent.title
      expect(page).to have_content @sibling.title
    end

    scenario 'Tab: All Data' do
      prepare_and_open_collection
      click_on_tab I18n.t(:media_entry_tab_more_data)
      expect(find('.meta-data-summary')).to have_content @collection.title
    end

    scenario 'Tab: Permissions', browser: :firefox do
      prepare_and_open_collection
      click_on_tab I18n.t(:media_entry_tab_permissions)
      find('.primary-button', text: 'Bearbeiten').click
      autocomplete_and_choose_first(person_section, @user.login)
      find('.primary-button', text: 'Speichern').click
      expect(person_section).to have_content(
        @user.person.first_name + ' ' + @user.person.last_name)
    end

    it 'Favorite-Button not visible in Toolbar when not logged in' do
      prepare_user
      @collection = create_collection('Test Collection')
      visit collection_path(@collection)
      favorite_check_logged_out
    end
  end

  def person_section
    xpath = './/div[contains(@class, "ui-rights-management-users")]'
    xpath += '[.//span[contains(.,"Personen")]]'
    find(:xpath, xpath)
  end

  describe 'Action: favor (when logged in)' do
    it 'works via Toolbar-Button on "show" View' do
      prepare_and_open_collection
      favorite_check_logged_in(@user, @collection)
    end
  end
end
