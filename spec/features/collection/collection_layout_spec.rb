require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'determine collection layout ' do

  scenario 'not logged in' do
    @collection = FactoryBot.create(:collection)
    @collection.get_metadata_and_previews = true
    @collection.save
    @collection.reload
    open_collection
    check_button(:invisible)
  end

  scenario 'logged in default' do
    open_set_logged_in
    check_set_layout(:grid)
    check_button(:disabled)
    check_thumbnail(:grid)
  end

  scenario 'change to tiles layout' do
    open_set_logged_in
    click_layout(:tiles)
    check_button(:active)
    check_thumbnail(:tiles)
    click_buttton
    check_button(:disabled)
    check_thumbnail(:tiles)
    check_set_layout(:tiles)
  end

  scenario 'reload with selected different from saved' do
    open_set_logged_in
    check_set_layout(:grid)
    click_layout(:tiles)
    page_reload
    check_thumbnail(:tiles)
    check_button(:active)
  end

  private

  def page_reload
    page.evaluate_script('window.location.reload()')
  end

  def open_collection
    visit collection_path(@collection)
  end

  def click_layout(layout)
    if layout == :tiles
      find('.ui-toolbar-controls').find('.icon-vis-pins').click
    else
      fail
    end
  end

  def check_set_layout(expected)
    if expected == :tiles
      check = 'tiles'
    elsif expected == :grid
      check = 'grid'
    else
      fail
    end
    expect(@collection.reload.layout).to eq(check)
  end

  def check_thumbnail(expected)
    if expected == :grid
      find('.ui-resources-page-items').find('.ui-thumbnail')
    elsif expected == :tiles
      find('.ui-resources-page-items').find('.ui-tile__thumbnail')
    else
      fail
    end
  end

  def click_buttton
    find('.ui-toolbar').find(
      'a', text: I18n.t(:collection_layout_save)).click
  end

  def check_button(expected)
    if expected == :invisible
      expect(find('.ui-toolbar')).to have_no_content(
        I18n.t(:collection_layout_save))
      expect(find('.ui-toolbar')).to have_no_content(
        I18n.t(:collection_layout_saved))
    elsif expected == :active
      button = find('.ui-toolbar').find(
        'a', text: I18n.t(:collection_layout_save))
      expect(button[:disabled]).to eq(nil)
    elsif expected == :disabled
      button = find('.ui-toolbar').find(
        'a', text: I18n.t(:collection_layout_saved))
      expect(button[:disabled]).to eq ''
      # The "button" is an `<a>` element, which does not officially support the `disabled`
      # attribute. This is why it's not treated as a binary attribute and can not be
      # tested with `expect(button).to be_disabled`.
    else
      fail
    end
  end

  def open_set_logged_in
    prepare_user
    login
    prepare_data
    open_collection
  end

  def prepare_data
    @collection = FactoryBot.create(:collection, responsible_user: @user)
    @media_entry = FactoryBot.create(:media_entry, responsible_user: @user)
    @collection.media_entries << @media_entry
  end
end
