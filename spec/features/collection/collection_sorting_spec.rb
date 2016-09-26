require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'collection sorting' do

  scenario 'sortable but not saveable when not logged in' do
    prepare_user
    prepare_collection_with_three_entries
    visit_collection

    expect_no_save_button

    check_children(:created_at_desc)
  end

  scenario 'read sorting from url' do
    prepare_user
    prepare_collection_with_three_entries
    login

    save_collection_sorting('created_at ASC')
    visit_collection_sorting('created_at DESC')
    check_dropdown(:collection_sorting_created_at_desc)
    check_children(:created_at_desc)
  end

  scenario 'save order' do
    prepare_user
    prepare_collection_with_three_entries
    login
    save_collection_sorting('created_at ASC')

    visit_collection
    check_dropdown(:collection_sorting_created_at_asc)
    check_children(:created_at_asc)
    expect_save_button(false)

    select_sorting(:collection_sorting_created_at_desc)
    expect_save_button(true)
    click_save_button
    wait_leaving_page_until_response

    visit_collection
    check_dropdown(:collection_sorting_created_at_desc)
    check_children(:created_at_desc)
    expect_save_button(false)
  end

  scenario 'read sorting from saved' do
    prepare_user
    prepare_collection_with_three_entries
    login

    save_collection_sorting('created_at ASC')
    visit_collection
    check_dropdown(:collection_sorting_created_at_asc)
    check_children(:created_at_asc)
  end

  scenario 'check disabled button' do
    prepare_user
    prepare_empty_collection
    login
    visit_collection
    expect_save_button(false)
  end

  scenario 'check sorting with mixed children' do
    prepare_user
    prepare_collection_with_mixed_children
    save_collection_sorting('created_at ASC')
    login
    visit_collection

    expected_created_at_asc = [
      '2 Media Entry',
      '1 Collection',
      '4 Media Entry',
      '3 Collection']
    expected_title_asc = [
      '1 Collection',
      '2 Media Entry',
      '3 Collection',
      '4 Media Entry']

    check_children_explicitly(expected_created_at_asc)
    select_sorting(:collection_sorting_created_at_desc)
    check_children_explicitly(expected_created_at_asc.reverse)
    select_sorting(:collection_sorting_title_asc)
    check_children_explicitly(expected_title_asc)
  end

  scenario 'check enabled button' do
    prepare_user
    prepare_empty_collection
    save_collection_sorting('created_at ASC')
    login
    visit_collection_sorting('created_at DESC')
    expect_save_button(true)
  end

  scenario 'change sorting on client and reload' do
    prepare_user
    prepare_collection_with_three_entries
    login

    save_collection_sorting('created_at ASC')

    visit_collection

    check_dropdown(:collection_sorting_created_at_asc)
    check_children(:created_at_asc)

    select_sorting(:collection_sorting_created_at_desc)

    check_dropdown(:collection_sorting_created_at_desc)
    check_children(:created_at_desc)

    page_reload

    check_dropdown(:collection_sorting_created_at_desc)
    check_children(:created_at_desc)
  end
end

def wait_leaving_page_until_response
  expect_save_button(false)
end

def select_sorting(sorting_text_key)
  within('.ui-polybox .ui-toolbar-controls') do
    find('.dropdown-toggle').click
    find('.dropdown-menu')
      .find('.ui-drop-item', text: I18n.t(sorting_text_key)).click
  end
end

def page_reload
  page.evaluate_script('window.location.reload()')
end

def check_dropdown(text_key)
  within('.ui-polybox .ui-toolbar-controls') do
    expect(page).to have_css('.dropdown-toggle', text: I18n.t(text_key))
  end
end

def check_children_explicitly(expected_titles)
  expect(titles_per_pages.flatten).to eq(expected_titles)
end

def titles_per_pages
  all('.ui-resources-page').map do |page_element|
    page_element
      .find('.ui-resources-page-items')
      .all('.ui-resource')
      .map do |item_element|

      item_element.find('.ui-thumbnail-meta-title').text
    end
  end
end

def check_children(sorting)
  expected =
    case sorting
    when :created_at_asc
      child_media_resources_titles
    when :created_at_desc
      child_media_resources_titles.reverse
    else
      throw 'Sorting not specified in the test: ' + sorting.to_s
    end

  expect(titles_per_pages.flatten).to eq(expected)
end

def child_media_resources_titles
  @media_entries.map &:title
end

def click_save_button
  find('.ui-polybox').find('a', text: I18n.t(:collection_layout_save)).click
end

def expect_save_button(active)
  text_key =
    if active
      :collection_layout_save
    else
      :collection_layout_saved
    end
  within('.ui-polybox') do
    expect(page).to have_css('a', text: I18n.t(text_key))
  end
end

def expect_no_save_button
  within('.ui-polybox') do
    expect(page).to have_no_css('a', text: I18n.t(:collection_layout_save))
    expect(page).to have_no_css('a', text: I18n.t(:collection_layout_saved))
  end
end

def save_collection_sorting(sorting)
  @parent_collection.sorting = sorting
  @parent_collection.save
  @parent_collection.reload
end

def prepare_collection_with_three_entries
  @parent_collection = create_collection('Test Collection')
  @media_entries = (1..3).map do |index|
    media_entry = create_media_entry('Media Entry ' + index.to_s)
    update_created_at_year(media_entry, 2000 + index)
    media_entry
  end
  @parent_collection.media_entries.concat(@media_entries)
  @parent_collection.save
  @parent_collection
end

def update_created_at_year(resource, year)
  resource.created_at = Date.new(year, 1, 1)
  resource.save
  resource.reload
  resource
end

def prepare_collection_with_mixed_children
  @parent_collection = create_collection('Test Collection')

  media_entry_1 = create_media_entry('4 Media Entry')
  update_created_at_year(media_entry_1, 2003)
  media_entry_2 = create_media_entry('2 Media Entry')
  update_created_at_year(media_entry_2, 2001)

  collection_1 = create_collection('1 Collection')
  update_created_at_year(collection_1, 2002)

  collection_2 = create_collection('3 Collection')
  update_created_at_year(collection_2, 2004)

  @parent_collection.media_entries.concat(
    [media_entry_1, media_entry_2])
  @parent_collection.collections.concat(
    [collection_1, collection_2])
  @parent_collection.save
  @parent_collection
end

def prepare_empty_collection
  @parent_collection = create_collection('Test Collection')
end

def visit_collection_sorting(sorting)
  visit collection_path(@parent_collection, list: { order: sorting })
end

def visit_collection
  visit collection_path(@parent_collection)
end
