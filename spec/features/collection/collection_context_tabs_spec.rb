require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

feature 'Collection Context Tabs' do

  scenario 'Show no context tabs if meta data is empty' do
    setup_contexts_for_collection_extra
    prepare_user
    login
    create_empty_collection
    visit_collection

    check_title('<Collection has no title>')
    check_tabs(['Set', 'Nutzung', 'Alle Metadaten', 'Berechtigungen'])
  end

  scenario 'Show context tabs if meta data available' do
    setup_contexts_for_collection_extra
    prepare_user
    login
    create_empty_collection
    add_collection_title('My Title')
    visit_collection

    check_tabs(
      ['Set', 'Core', 'Werk', 'Nutzung', 'Alle Metadaten', 'Berechtigungen'])
    click_tab('Core')
    check_meta_data
  end

  def check_meta_data
    within('.ui-metadata-box') do
      expect(all('.ui-summary-label').length).to eq(1)
      find('.ui-summary-label', text: 'Titel')
      find('.ui-summary-content', text: 'My Title')
    end
  end

  def click_tab(tab_text)
    find('.app-body').find('.ui-tabs')
      .find('.ui-tabs-item', text: tab_text).click
  end

  def check_tabs(expected_tabs)
    tabs = find('.app-body').find('.ui-tabs').all('.ui-tabs-item')

    expect(tabs.length).to eq(expected_tabs.length)

    expected_tabs.zip(tabs).each do |pair|
      expected = pair.first
      actual = pair.last

      actual.find('a', text: expected)
    end
  end

  def check_title(expected_title)
    find('.ui-body-title').find('.title-xl', text: expected_title)
  end

  def setup_contexts_for_collection_extra
    app_settings = AppSetting.first
    app_settings[:contexts_for_collection_extra].concat ['core', 'media_content']
    app_settings.save
  end

  def visit_collection
    visit collection_path(@collection)
  end

  def create_empty_collection
    @collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
  end

  def add_collection_title(title)
    MetaDatum::Text.create!(
      collection: @collection,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
  end
end
