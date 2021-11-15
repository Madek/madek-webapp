require 'spec_helper'
require 'spec_helper_feature'

feature 'Collection: resource actions' do
  let(:user) { create(:user, password: 'password123') }
  let(:collection) { create(:collection, responsible_user: user) }

  background do
    sign_in_as user, 'password123'
    visit collection_path(collection)
    expect_no_modal
  end

  scenario 'displays "Create set" in "Actions" menu' do
    expect(page).to have_css('.ui-resources-page-items .ui-resource', count: 0)

    find('.dropdown-toggle', exact_text: I18n.t('resources_box_batch_actions_menu_title')).click

    within '.dropdown.open .dropdown-menu' do
      click_link(I18n.t('resource_action_collection_create'))
    end

    expect_modal

    within '.modal' do
      fill_in 'collection_title', with: 'Nested Collection'
      click_button I18n.t('collection_new_create_set')
    end

    expect_no_modal

    within '.ui-resources-page-items' do
      expect(page).to have_css('.ui-resource', text: 'Nested Collection')
    end
  end
end

def expect_no_modal
  expect(page).not_to have_css('.modal', text: I18n.t('collection_new_dialog_title'))
  expect(page).not_to have_css('.modal', text: I18n.t('collection_new_dialog_parent_warning'))
end

def expect_modal
  expect(page).to have_css('.modal', text: I18n.t('collection_new_dialog_title'))
  expect(page).to have_css('.modal', text: I18n.t('collection_new_dialog_parent_warning') +
                                           ' ' +
                                           collection.title)
end
