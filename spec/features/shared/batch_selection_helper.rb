# rubocop:disable Metrics/ModuleLength
module BatchSelectionHelper

  def click_batch_action(key, all: false, all_count: - 1)
    entry = expected_label_and_count(key, all: all, count: all_count)

    find('[data-test-id=resources_box_dropdown]')
      .find('.ui-drop-item', text: entry[:text]).click
  end

  def check_partial_dropdown(expected_counts)
    no_unknown_keys = (expected_counts.keys - all_logical_menu_keys).empty?
    expect(no_unknown_keys).to eq(true)

    check_dropdown(expected_counts)
  end

  def check_full_dropdown(expected_counts)
    expect(expected_counts.keys.sort).to eq(all_logical_menu_keys.sort)

    within '[data-test-id=resources_box_dropdown]' do
      expect(page).to have_selector(
        '.ui-drop-item', count: expected_counts.keys.length)
    end

    check_dropdown(expected_counts)
  end

  def check_menu_config(menu_config)
    if menu_config[:count] == 0 ||
      menu_config[:active] == false ||
      menu_config[:highlights] == []
      expect(menu_config[:count]).to eq(0)
      expect(menu_config[:active]).to eq(false)
      if menu_config[:highlights]
        expect(menu_config[:highlights]).to eq([])
      end
    end
  end

  def expected_clipboard_label_and_count(count:, all:)
    if all
      rcount = nil
      text = I18n.t(:resources_box_batch_actions_addalltoclipboard_1) \
        + count.to_s \
        + I18n.t(:resources_box_batch_actions_addalltoclipboard_2)
    else
      rcount = count
      text = I18n.t(:resources_box_batch_actions_addselectedtoclipboard)
    end
    {
      count: rcount,
      text: text
    }
  end

  def expected_media_entries_label_and_count(count:, all:)
    if all
      rcount = nil
      text = I18n.t(:resources_box_batch_actions_edit_all_media_entries)
    else
      rcount = count
      text = I18n.t(:resources_box_batch_actions_edit)
    end
    {
      count: rcount,
      text: text
    }
  end

  def expected_collections_label_and_count(count:, all:)
    if all
      rcount = nil
      text = I18n.t(:resources_box_batch_actions_edit_all_collections)
    else
      rcount = count
      text = I18n.t(:resources_box_batch_actions_edit_sets)
    end
    {
      count: rcount,
      text: text
    }
  end

  def expected_label_and_count(key, count: nil, all: nil)
    if key == :add_to_clipboard
      expected_clipboard_label_and_count(count: count, all: all)
    elsif key == :media_entries_metadata
      expected_media_entries_label_and_count(count: count, all: all)
    elsif key == :collections_metadata
      expected_collections_label_and_count(count: count, all: all)
    else
      {
        count: count.to_s,
        text: I18n.t(text_keys[key])
      }
    end
  end

  def check_label_and_count(key, menu_config, text, count)
    within '[data-test-id=resources_box_dropdown]' do
      item = find('.ui-drop-item', text: text)
      if count
        expect(item).to(
          have_css('.ui-count', text: count),
          'Wrong count for: ' + key.to_s
        )
      else
        expect(item).to(
          have_no_css('.ui-count'))
      end

      if menu_config[:active] == false
        find('.ui-drop-item.disabled', text: text)
      else
        find('.ui-drop-item:not([class*=disabled])', text: text)
      end
    end
  end

  def check_highlights(menu_config, text)
    highlights = menu_config[:highlights]
    if highlights
      within '[data-test-id=resources_box_dropdown]' do
        find('.ui-drop-item', text: text).hover
      end

      highlighted_titles = highlights.map(&:title)

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

  def check_dropdown(expected_counts)
    expected_counts.keys.each do |key|

      if expected_counts.include?(key)

        menu_config = expected_counts[key]

        check_menu_config(menu_config)

        label_and_count = expected_label_and_count(
          key, count: menu_config[:count], all: menu_config[:all])

        check_label_and_count(
          key,
          menu_config,
          label_and_count[:text],
          label_and_count[:count])

        check_highlights(menu_config, label_and_count[:text])
      else
        raise 'not expected'
      end
    end
  end

  def select_media_entries(media_entries)
    select_shared(MediaEntry, media_entries)
  end

  def select_collections(collections)
    select_shared(Collection, collections)
  end

  def select_mixed(resources)
    select_shared(
      MediaEntry,
      resources.select { |resource| resource.class == MediaEntry }
    )
    select_shared(
      Collection,
      resources.select { |resource| resource.class == Collection }
    )
  end

  def select_shared(type, resources)
    thumbnails = find('.ui-polybox')
      .all('.' + resource_thumbnail_class(type) + '.ui-thumbnail')

    thumbnails.each do |thumbnail|
      title = thumbnail.find('.ui-thumbnail-meta-title').text
      next unless resources.map(&:title).include?(title)

      thumbnail.hover
      actions = thumbnail.find('.ui-thumbnail-actions')
      actions.hover
      actions.find('.ui-thumbnail-action-checkbox').click
    end
  end

  def toggle_select_all
    find('.ui-filterbar-select').find('i').click
  end

  def resource_thumbnail_class(type)
    if type == MediaEntry
      'media-entry'
    elsif type == Collection
      'media-set'
    else
      raise 'Not supported class'
    end
  end

  def click_dropdown
    within '[data-test-id=resources_box_dropdown]' do
      find('.dropdown-toggle').click
    end
  end

  def all_logical_menu_keys
    [
      :add_to_clipboard,
      :add_to_set,
      :remove_from_set,
      :media_entries_metadata,
      :collections_metadata,
      :resources_destroy,
      :media_entries_permissions,
      :collections_permissions,
      :media_entries_transfer_responsibility,
      :collections_transfer_responsibility
    ]
  end

  def text_keys
    {
      add_to_set: :resources_box_batch_actions_addtoset,
      remove_from_set: :resources_box_batch_actions_removefromset,
      media_entries_metadata: :resources_box_batch_actions_edit,
      collections_metadata: :resources_box_batch_actions_edit_sets,
      resources_destroy: :resources_box_batch_actions_delete,
      media_entries_permissions:
        :resources_box_batch_actions_managepermissions,
      collections_permissions:
        :resources_box_batch_actions_sets_managepermissions,
      media_entries_transfer_responsibility:
        :resources_box_batch_actions_transfer_responsibility_entries,
      collections_transfer_responsibility:
        :resources_box_batch_actions_transfer_responsibility_sets,
      media_entries_edit_all:
        :resources_box_batch_actions_edit_all_media_entries,
      collections_edit_all:
        :resources_box_batch_actions_edit_all_collections
    }
  end
end
# rubocop:enable Metrics/ModuleLength
