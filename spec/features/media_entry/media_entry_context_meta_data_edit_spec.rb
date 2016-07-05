require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/meta_data_helper_spec'
include MetaDataHelper

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Resource: MediaEntry' do
  describe 'Concern: MetaData' do

    it 'open default context (no-js)', browser: :firefox_nojs do
      direct_open_context(nil, false, 'zhdk_bereich')
    end

    it 'open media_content context (no-js)', browser: :firefox_nojs do
      direct_open_context('media_content', false, 'zhdk_bereich')
    end

    it 'open default context (js)', browser: :firefox do
      direct_open_context(nil, true, 'zhdk_bereich')
    end

    it 'open media_content context (js)', browser: :firefox do
      direct_open_context('media_content', true, 'zhdk_bereich')
    end
  end
end

def initialize_and_check_show
  prepare_data
  login

  visit media_entry_path(@resource)
  expect(page).to have_content(I18n.t(:media_entry_not_published_warning_msg))
end

def goto_initial_context_edit(context, async, switch_to)
  visit edit_context_path(context)
  check_selected_tab(context)

  open_context(switch_to, async)

  expect(@resource.is_published).to eq(false)

  expect(save_button.disabled?).to eq(async)
end

def edit_some_data(async)
  update_context_text_field(@key_prj_title, @project_title)
  if async
    update_context_checkbox(@key_prj_type, @project_type_forschung)
    update_context_bubble(@key_group, @bachelor_design)
  else
    update_context_bubble_no_js(@key_prj_type, @project_type_forschung)
    update_context_bubble_no_js(@key_group, @bachelor_design)
  end

  expect(save_button.disabled?).to eq(false)
end

def goto_core_and_back(async, switch_to)
  open_context('core', async)

  expect(save_button.disabled?).to eq(false)

  update_context_text_field('madek_core:title', @core_title)

  open_context(switch_to, async)
end

def check_data_still_there(async)
  if async
    expect(read_context_text_field(@key_prj_title)).to eq(@project_title)
    expect(
      read_context_checkbox(
        @key_prj_type,
        @project_type_forschung)).to eq(true)
  else
    expect(read_context_text_field(@key_prj_title)).to eq('')
    expect(read_context_bubble_no_js(@key_prj_type)).to eq('')
    expect(read_context_bubble_no_js(@key_group)).to eq('')
  end

  expect(save_button.disabled?).to eq(false)
end

def save_first_time(async)
  expect(@resource.meta_data.length).to eq(1)
  save_button.click
  expect(current_path).to eq(media_entry_path(@resource))

  expect(page).to have_content(
    I18n.t(:meta_data_edit_media_entry_saved_missing))

  if async
    expect(@resource.reload.meta_data.length).to eq(4)
  else
    expect(@resource.reload.meta_data.length).to eq(1)
  end
end

def save_second_time(async)
  click_action_button('pen')

  update_context_text_field('madek_core:copyright_notice', @copyright)

  save_button.click

  expect(current_path).to eq(media_entry_path(@resource))

  if async
    expect(page).to have_content(
      I18n.t(:meta_data_edit_media_entry_published))
  else
    expect(page).to have_content(
      I18n.t(:meta_data_edit_media_entry_saved_missing))
  end

  if async
    expect(@resource.reload.is_published).to eq(true)
    expect(@resource.reload.meta_data.length).to eq(5)
  else
    expect(@resource.reload.is_published).to eq(false)
    expect(@resource.reload.meta_data.length).to eq(2)
  end
end

def save_third_time(async)
  click_action_button('pen')

  expect(save_button.disabled?).to eq(true) if async

  update_context_text_field('madek_core:subtitle', 'Test')

  expect(save_button.disabled?).to eq(false)

  clear_context_text_field('madek_core:title')

  expect(save_button.disabled?).to eq(true) if async

  update_context_text_field('madek_core:title', 'New Title')

  expect(save_button.disabled?).to eq(false) if async

  save_button.click

  expect(current_path).to eq(media_entry_path(@resource))

  if async
    expect(page).to have_content(
      I18n.t(:meta_data_edit_media_entry_saved))
  else
    expect(page).to have_content(
      I18n.t(:meta_data_edit_media_entry_saved_missing))
  end
end

def direct_open_context(context, async, switch_to)
  initialize_and_check_show
  goto_initial_context_edit(context, async, switch_to)
  edit_some_data(async)
  goto_core_and_back(async, switch_to)
  check_data_still_there(async)
  save_first_time(async)
  save_second_time(async)
  save_third_time(async)
end

def save_button
  find('button', text: I18n.t(:meta_data_form_save))
end

def prepare_data
  prepare_user
  @resource = create_media_entry('Test Media Entry')
  @resource.reload

  @key_group = 'zhdk_bereich:institutional_affiliation'
  @key_prj_type = 'zhdk_bereich:project_type'
  @key_prj_title = 'zhdk_bereich:project_title'

  @project_type_forschung = create_or_find_keyword('Forschung')
  @bachelor_design = create_or_find_group('Bachelor Design')
  @project_title = 'Test Title'
  @core_title = 'Core Title'
  @copyright = 'My Copyright'

  first = AppSetting.first
  first.contexts_for_validation = ['upload']
  first.save!

  @resource.is_published = false
  @resource.save!
end
