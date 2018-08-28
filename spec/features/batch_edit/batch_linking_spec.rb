require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper
require_relative '../shared/batch_data_helper'
include BatchDataHelper

feature 'Batch linking' do

  scenario 'Add to set' do
    prepare_and_login_and_visit_collection
    select_mixed(mixed_1_3_1_3)
    select_menu_by_key(:add_to_set)

    title = I18n.t(:batch_add_to_collection_pre) + 4.to_s +
      I18n.t(:batch_add_to_collection_post)
    find('.modal').find('.ui-modal-head', text: title.strip)
  end

  scenario 'Remove from set' do
    prepare_and_login_and_visit_collection
    select_mixed(mixed_1_3_1_3)
    select_menu_by_key(:remove_from_set)

    title =
      I18n.t(:batch_remove_from_collection_question_part_1) + 2.to_s +
      I18n.t(:batch_remove_from_collection_question_part_2) + 2.to_s +
      I18n.t(:batch_remove_from_collection_question_part_3)
    find('.modal').find('.ui-modal-body', text: title.strip)
  end

  scenario 'Media entries metadata' do
    prepare_and_login_and_visit_collection
    select_mixed(mixed_1_3_1_3)
    select_menu_by_key(:media_entries_metadata)

    title =
      I18n.t(:meta_data_batch_title_pre) + 2.to_s +
      I18n.t(:meta_data_batch_title_post_media_entries)
    find('.ui-body-title', text: title.strip)

    expect(current_path).to eq(
      batch_edit_meta_data_by_context_media_entries_path(nil))
    check_resources(media_entries_1_3)
  end

  scenario 'Collections metadata' do
    prepare_and_login_and_visit_collection
    select_mixed(mixed_1_3_1_3)
    select_menu_by_key(:collections_metadata)

    title =
      I18n.t(:meta_data_batch_title_pre) + 2.to_s +
      I18n.t(:meta_data_batch_title_post_collections)
    find('.ui-body-title', text: title.strip)

    expect(current_path).to eq(
      batch_edit_meta_data_by_context_collections_path(nil))
    check_resources(collections_1_3)
  end

  scenario 'Media entries permissions' do
    prepare_and_login_and_visit_collection
    select_mixed(mixed_1_3_1_3)
    select_menu_by_key(:media_entries_permissions)

    title =
      I18n.t(:permissions_batch_title_pre) + 2.to_s +
      I18n.t(:permissions_batch_title_post)
    find('.ui-body-title', text: title.strip)

    expect(current_path).to eq(
      batch_edit_permissions_media_entries_path(nil))
    check_resources(media_entries_1_3)
  end

  def check_resources(resources)
    within('.ui-resources-holder') do
      resources.each do |r|
        base = \
          if r.class == MediaEntry then 'entries'
          elsif r.class == Collection then 'sets'
          else
            throw 'unexpected'
          end
        href = '/' + base + '/' + r.id
        find('.ui-resource a[href="' + href + '"]')
      end
    end
  end

  def prepare_and_login_and_visit_collection
    prepare_user
    prepare_data
    login
    visit collection_path(@parent_collection)
  end

  def select_menu_by_key(key)
    click_dropdown
    text_keys[key]
    within '[data-test-id=resources_box_dropdown]' do
      find('.ui-drop-item', text: I18n.t(text_keys[key])).click
    end
  end
end
