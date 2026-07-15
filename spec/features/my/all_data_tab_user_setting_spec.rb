require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'User setting for the all metadata edit tab' do
  it 'controls the tab visibility' do
    prepare_user
    @user.update!(settings: {})
    media_entry = create_media_entry('Entry')
    collection = create_collection('Set')
    login

    visit my_settings_path
    expect(page).to have_unchecked_field('showAllDataTabInEditMode')

    [media_entry_path(media_entry), collection_path(collection)].each do |path|
      expect_all_data_tab(path, visible: false)
    end

    visit my_settings_path
    check('showAllDataTabInEditMode')
    click_on(I18n.t(:settings_save_changes))
    expect(page).to have_checked_field('showAllDataTabInEditMode')
    expect(page).to have_content(I18n.t(:settings_saved_changes))

    [media_entry_path(media_entry), collection_path(collection)].each do |path|
      expect_all_data_tab(path, visible: true)
    end
  end
end

def expect_all_data_tab(path, visible:)
  visit(path)

  within('.app-body .ui-tabs') do
    expect(page).to have_selector(
      '.ui-tabs-item', text: I18n.t(:media_entry_tab_more_data), exact_text: true)
    expect(page).to have_no_selector(
      '.ui-tabs-item', text: I18n.t(:meta_data_form_all_data), exact_text: true)
  end

  find('.icon-pen').click

  within('.app-body .ui-tabs') do
    expect(page).to have_no_selector(
      '.ui-tabs-item', text: I18n.t(:media_entry_tab_more_data), exact_text: true)

    matcher = have_selector(
      '.ui-tabs-item', text: I18n.t(:meta_data_form_all_data), exact_text: true)
    visible ? expect(page).to(matcher) : expect(page).not_to(matcher)
  end
end
