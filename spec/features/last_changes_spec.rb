require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/basic_data_helper_spec'
include BasicDataHelper
require_relative 'shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

feature 'display last changes' do

  scenario 'collection' do
    prepare_user
    prepare_collection
    login

    visit_collection_more_data
    check_title
    check_empty

    add_collection_edit_session

    visit_collection_more_data
    check_title
    check_entry
    check_count(1)

    make_public_collection
    logout
    visit_collection_more_data
    check_not_shown
  end

  scenario 'media entry' do
    prepare_user
    prepare_media_entry
    login

    visit_media_entry_more_data
    check_title
    check_empty

    add_media_entry_edit_session

    visit_media_entry_more_data
    check_title
    check_entry
    check_count(1)

    make_public_media_entry
    logout
    visit_media_entry_more_data
    check_not_shown
  end

  scenario 'maximum 5' do
    prepare_user
    prepare_collection

    add_collection_edit_session
    add_collection_edit_session
    add_collection_edit_session
    add_collection_edit_session
    add_collection_edit_session
    add_collection_edit_session

    login

    visit_collection_more_data
    check_count(5)
  end
end

def add_media_entry_edit_session
  EditSession.create! Hash[:user, @user,
                           'media_entry', @media_entry]
end

def add_collection_edit_session
  EditSession.create! Hash[:user, @user,
                           'collection', @collection]
end

def set_title
  update_context_text_field('core', 'madek_core:title', 'New Value')
end

def open_edit_meta_data
  find('.ui-body-title-actions').find('.icon-pen').click
end

def click_save
  find('.ui-actions')
    .find('.primary-button', text: I18n.t(:meta_data_form_save))
    .click
end

def check_title
  find('.tab-content').find(
    '.title-l', text: I18n.t(:usage_data_last_changes_title))
end

def check_count(count)
  entries = find('.title-l', text: I18n.t(:usage_data_last_changes_title))
    .find(:xpath, './..')
    .all('.ui-summary-content')
  expect(entries.length).to eq(count)
end

def check_entry
  find('.tab-content')
    .find('.title-l', text: I18n.t(:usage_data_last_changes_title))
    .find(:xpath, './..')
    .find('.ui-summary-content', text: @user.to_s)
end

def check_not_shown
  expect(page).to have_no_css(
    '.title-l', text: I18n.t(:usage_data_last_changes_title))
end

def check_empty
  find('.tab-content', text: I18n.t(:usage_data_last_changes_empty))
end

def make_public_collection
  @collection.get_metadata_and_previews = true
  @collection.save
  @collection.reload
end

def make_public_media_entry
  @media_entry.get_metadata_and_previews = true
  @media_entry.save
  @media_entry.reload
end

def prepare_collection
  @collection = create_collection('Collection')
end

def prepare_media_entry
  @media_entry = create_media_entry('Media Entry')
end

def visit_media_entry_more_data
  visit usage_data_media_entry_path(@media_entry)
end

def visit_collection_more_data
  visit usage_data_collection_path(@collection)
end
