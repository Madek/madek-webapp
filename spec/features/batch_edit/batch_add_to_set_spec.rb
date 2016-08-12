require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/meta_data_helper_spec'
include MetaDataHelper

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'batch edit' do
  describe 'batch add to set' do

    it 'cancel button (no-js)', browser: :firefox_nojs do
      prepare_data
      login

      open_batch_select_add_to_set
      check_default_initial_content(false)

      open_batch_select_add_to_set
      cancel_button.click
      check_return_to_page

      open_batch_select_add_to_set
      cancel_cross.click
      check_return_to_page
    end

    it 'search and clear (no-js)', browser: :firefox_nojs do
      prepare_data
      login

      open_batch_select_add_to_set

      search('Test')
      check_search_result('Test', [], false)

      search('Collection')
      check_search_result('Collection', [@collection1, @collection2], false)

      search('Collection1')
      check_search_result('Collection1', [@collection1], false)

      search('Collection2')
      check_search_result('Collection2', [@collection2], false)

      search('')
      check_search_result('', [], false)
    end

    it 'cancel button (js)' do
      prepare_data
      login

      visit @unpublished_entries_path
      select_all_box.click

      select_set_button.click
      check_default_initial_content(true)
      check_path(@unpublished_entries_path)
      cancel_button.click
      check_path(@unpublished_entries_path)
      check_no_dialog

      select_set_button.click
      check_default_initial_content(true)
      check_path(@unpublished_entries_path)
      cancel_cross.click
      check_path(@unpublished_entries_path)
      check_no_dialog
    end
  end

  it 'search (js)' do
    prepare_data
    login

    visit @unpublished_entries_path
    select_all_box.click
    select_set_button.click
    check_default_initial_content(true)
    check_path(@unpublished_entries_path)

    search_async('Test')
    check_search_result('Test', [], true)

    search_async('Collection')
    check_search_result('Collection', [@collection1, @collection2], true)

    search_async('Collection1')
    check_search_result('Collection1', [@collection1], true)

    search_async('Collection2')
    check_search_result('Collection2', [@collection2], true)

    clear_async(search_input)
    check_search_result('', [], true)
  end

  def prepare_data
    prepare_user
    @unpublished_entries_path = '/my/content_media_entries'
    @return_to_path = '/my'

    @media_entry1 = create_media_entry('MediaEntry1')
    @media_entry2 = create_media_entry('MediaEntry2')

    @collection1 = create_collection('Collection1')
    @collection2 = create_collection('Collection2')
  end

  def check_path(path)
    expect(current_path).to eq(path)
  end

  def check_no_dialog
    expect(all('.modal').size).to eq(0)
  end

  def initial_url
    batch_select_add_to_set_path(
      resource_id: [
        {
          uuid: @media_entry1.id,
          type: 'MediaEntry'
        },
        {
          uuid: @media_entry2.id,
          type: 'MediaEntry'
        }
      ],
      return_to: @return_to_path)
  end

  def open_batch_select_add_to_set
    visit initial_url
  end

  def select_all_box
    within('.app-body-content') do
      find('.ui-filterbar').find('.icon-checkbox')
    end
  end

  def select_set_button
    menu_text = I18n.t('resources_box_batch_actions_menu_title', raise: false)
    action_text = I18n.t('resources_box_batch_actions_addtoset')
    within('.ui-filterbar') do
      dropdown_menu_and_get(menu_text, action_text)
    end
  end

  def search(search_term)
    search_input.set(search_term)
    search_button.click
  end

  def search_async(search_term)
    search_input.set(search_term)
  end

  def clear_async(input)
    unless input.value.empty?
      input.set(input.value[0])
    end
    input.click
    input.native.send_keys(:backspace) until input.value.empty?
  end

  def check_title(count)
    title = I18n.t(:batch_add_to_collection_pre) +
      count.to_s + I18n.t(:batch_add_to_collection_post)

    expect(page).to have_content(title)
  end

  def check_initial_hint
    expect(page).to have_content(I18n.t(:batch_add_to_collection_hint))
  end

  def check_default_initial_content(async)
    check_title(2)

    check_initial_hint

    search_input
    unless async
      search_button
      clear_button
    end
    cancel_button
    cancel_cross
  end

  def check_search_result_page(async)
    if async
      expect(current_path).to eq(@unpublished_entries_path)
    else
      expect(current_path).to eq(batch_select_add_to_set_path)
    end
  end

  def check_search_result(expected_search_string, expected_results, async)
    check_search_result_page(async)
    expect(search_input.value).to eq(expected_search_string)

    if expected_search_string.empty?
      check_initial_hint
    else
      check_hint_non_found(expected_results.empty?)
    end

    unless expected_results.empty?

      expected_results.each do |expected_result|
        find('.ui-modal-body').find('ol').find(
          'span', text: expected_result.title)
      end
      rows = find('.ui-modal-body').find('ol').all('li')
      expect(rows.size).to eq(expected_results.length)
    end
  end

  def check_hint_non_found(visible)
    within('.ui-modal-body') do
      if visible
        expect(page).to have_content(
          I18n.t(:resource_select_collection_non_found))
      else
        expect(page).not_to have_content(
          I18n.t(:resource_select_collection_non_found))
      end
    end
  end

  def search_input
    within('.ui-search') do
      find('input')
    end
  end

  def search_button
    within('.ui-search') do
      find('.button', text: I18n.t(:resource_select_collection_search))
    end
  end

  def clear_button
    within('.ui-search') do
      find('.button', text: I18n.t(:resource_select_collection_clear))
    end
  end

  def cancel_button
    within('.ui-modal-footer') do
      find('.primary-button', I18n.t(:resource_select_collection_cancel))
    end
  end

  def cancel_cross
    within('.ui-modal-head') do
      find('.icon-close')
    end
  end

  def check_return_to_page
    expect(current_path).to eq(@return_to_path)
  end
end
