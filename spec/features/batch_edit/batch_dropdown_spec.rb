require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

feature 'Batch dropdown' do

  scenario 'Check dropdown menu and highlighting according to selection' do
    prepare_user
    prepare_data
    login
    visit collection_path(@parent_collection)

    open_dropdown
    check_all_items_inactive
    check_counts(
      add_to_set: 0,
      remove_from_set: 0,
      media_entries_metadata: 0,
      collections_metadata: 0,
      media_entries_permissions: 0
    )

    toggle_select_all

    open_dropdown
    check_all_items_active
    check_counts(
      add_to_set: 6,
      remove_from_set: 6,
      media_entries_metadata: 3,
      collections_metadata: 3,
      media_entries_permissions: 3
    )
    check_highlights(
      add_to_set: all_resources,
      remove_from_set: all_resources,
      media_entries_metadata: media_entries_1_2_3,
      collections_metadata: collections_1_2_3,
      media_entries_permissions: media_entries_1_2_3
    )

    toggle_select_all
    select_media_entries(media_entries_1_3)

    open_dropdown
    check_items_active(
      [
        :add_to_set,
        :remove_from_set,
        :media_entries_metadata,
        :media_entries_permissions
      ]
    )
    check_counts(
      add_to_set: 2,
      remove_from_set: 2,
      media_entries_metadata: 2,
      collections_metadata: 0,
      media_entries_permissions: 2
    )
    check_highlights(
      add_to_set: media_entries_1_3,
      remove_from_set: media_entries_1_3,
      media_entries_metadata: media_entries_1_3,
      collections_metadata: [],
      media_entries_permissions: media_entries_1_3
    )

    toggle_select_all
    select_collections(collections_1_3)

    open_dropdown
    check_items_active(
      [
        :add_to_set,
        :remove_from_set,
        :collections_metadata
      ]
    )
    check_counts(
      add_to_set: 2,
      remove_from_set: 2,
      media_entries_metadata: 0,
      collections_metadata: 2,
      media_entries_permissions: 0
    )
    check_highlights(
      add_to_set: collections_1_3,
      remove_from_set: collections_1_3,
      media_entries_metadata: [],
      collections_metadata: collections_1_3,
      media_entries_permissions: []
    )
  end

  def check_highlights(key_resources)
    text_keys.each do |key, text_key|
      find('[data-test-id=resources_box_dropdown]')
        .find('.ui-drop-item', text: I18n.t(text_key)).hover

      resources = key_resources[key]

      highlighted_titles = resources.map(&:title)

      find('.ui-polybox').find('.ui-resources-page-items')
        .all('.ui-resource').each do |thumbnail|

        title = thumbnail.find('.ui-thumbnail-meta-title').text

        if highlighted_titles.include?(title)
          thumbnail.assert_not_matches_selector('[style*=opacity]')
        else
          thumbnail.assert_matches_selector('[style*=opacity]')
        end
      end
    end
  end

  def check_counts(counts)
    text_keys.each do |key, text_key|
      within '[data-test-id=resources_box_dropdown]' do
        if counts.include?(key)
          expect(
            find('.ui-drop-item', text: I18n.t(text_key))
          ).to have_css('.ui-count', text: counts[key])
        else
          expect(
            find('.ui-drop-item', text: I18n.t(text_key)).find('.ui-count').text
          ).to eq('')
        end
      end
    end
  end

  def check_all_items_inactive
    check_items_active([])
  end

  def check_all_items_active
    check_items_active(text_keys.map { |key, text_key| key })
  end

  def check_items_active(active_items)
    text_keys.each do |key, text_key|
      within '[data-test-id=resources_box_dropdown]' do
        if active_items.include?(key)
          find('.ui-drop-item:not([class*=disabled])', text: I18n.t(text_key))
        else
          find('.ui-drop-item.disabled', text: I18n.t(text_key))
        end
      end
    end
  end
end
