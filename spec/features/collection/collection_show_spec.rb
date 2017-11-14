require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

feature 'Resource: Collections' do
  def prepare_data(admin: false)
    prepare_user(admin: admin)
    @collection = create_collection('Test Collection')
  end

  def open_collection
    login
    visit collection_path(@collection)
  end

  def prepare_and_open_collection(admin: false)
    prepare_data(admin: admin)
    open_collection
  end

  describe 'Action: show' do
    it 'is rendered', browser: false do
      prepare_and_open_collection
      expect(page.status_code).to eq 200
    end

    scenario 'Tab: Main' do
      prepare_and_open_collection
      # page title:
      expect(page.find('.ui-body-title')).to have_content @collection.title
      # meta data:
      expect(page).to have_content "Titel #{@collection.title}"
    end

    context 'Tab: Relations' do
      example 'is not show when there are no relations' do
        prepare_data
        open_collection
        tabs = find('.app-body .ui-tabs.large')
        expect(tabs).to have_content I18n.t(:media_entry_tab_more_data)
        expect(tabs).to_not have_content I18n.t(:media_entry_tab_relations)
      end

      example 'is show when there are relations' do
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
    end

    scenario 'Tab: All Data' do
      prepare_and_open_collection
      click_on_tab I18n.t(:media_entry_tab_more_data)
      expect(find('.meta-data-summary')).to have_content @collection.title
    end

    context 'Tab: Permissions' do
      example 'shows permissions' do
        prepare_and_open_collection
        click_on_tab I18n.t(:media_entry_tab_permissions)
        find('.primary-button', text: 'Bearbeiten').click

        person_row = subject_row find_form, I18n.t(:permission_subject_title_users)
        autocomplete_and_choose_first(person_row, @user.login)
        find('.primary-button', text: 'Speichern').click

        person_row = subject_row find_form, I18n.t(:permission_subject_title_users)
        expect(person_row).to have_content(
          @user.person.first_name + ' ' + @user.person.last_name)
      end

      example 'is not shown when not logged in' do
        prepare_data
        visit collection_path(@collection)
        tabs = find('.app-body .ui-tabs.large')
        expect(tabs).to have_content I18n.t(:media_entry_tab_more_data)
        expect(tabs).to_not have_content I18n.t(:media_entry_tab_permissions)
      end
    end

    it 'Favorite-Button not visible in Toolbar when not logged in' do
      prepare_user
      @collection = create_collection('Test Collection')
      visit collection_path(@collection)
      favorite_check_logged_out
    end
  end

  describe 'Action: favor (when logged in)' do
    it 'works via Toolbar-Button on "show" View' do
      prepare_and_open_collection
      favorite_check_logged_in(@user, @collection)
    end
  end

  context '(for public/no user logged in)' do
    it 'does not display link to admin' do
      prepare_and_open_collection

      within '.ui-body-title-actions .dropdown' do
        find('a').click
      end
      within '.dropdown.open' do
        expect(page).not_to have_link I18n.t(:resource_action_show_in_admin)
      end
    end
  end

  context '(for logged in user)' do
    it 'does not display link to admin' do
      prepare_and_open_collection

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
      prepare_and_open_collection(admin: true)
    end

    it 'displays link to admin' do
      within '.ui-body-title-actions .dropdown' do
        find('a').click
      end
      within '.dropdown.open' do
        expect(page).to have_link(
          I18n.t(:resource_action_show_in_admin),
          href: admin_collection_path(@collection)
        )
      end
    end
  end
end

#

def find_form
  page.find('form[name="ui-rights-management"]')
end

def subject_row(form, title)
  header = form.first('table thead', text: title)
  header.find(:xpath, '../../..') if header
end
