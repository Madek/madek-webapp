module BatchSelectionHelper

  def click_batch_action(key)
    text_key = text_keys[key]
    find('[data-test-id=resources_box_dropdown]')
      .find('.ui-drop-item', text: I18n.t(text_key)).click
  end

  def check_given_highlights(expected_highlights)
    some_text_keys = text_keys.select do |text_key|
      true if expected_highlights[text_key]
    end
    check_highlights(some_text_keys, expected_highlights)
  end

  def check_all_highlights(expected_highlights)
    check_highlights(text_keys, expected_highlights)
  end

  def check_highlights(some_text_keys, key_resources)
    some_text_keys.each do |key, text_key|
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

  def check_given_counts(expected_counts)
    some_text_keys = text_keys.select do |text_key|
      true if expected_counts[text_key]
    end
    check_counts(some_text_keys, expected_counts)
  end

  def check_all_counts(expected_counts)
    check_counts(text_keys, expected_counts)
  end

  def check_counts(to_check, counts)
    to_check.each do |key, text_key|
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
    active_items = {}
    text_keys.keys.each do |text_key|
      active_items[text_key] = false
    end
    check_items_active(text_keys, active_items)
  end

  def check_all_items_active
    active_items = {}
    text_keys.keys.each do |text_key|
      active_items[text_key] = true
    end
    check_items_active(text_keys, active_items)
  end

  def check_given_items_active(active_items)
    some_text_keys = text_keys.select do |text_key|
      true if active_items[text_key]
    end
    check_items_active(some_text_keys, active_items)
  end

  def check_items_active(some_keys, active_items)
    some_keys.each do |key, text_key|
      within '[data-test-id=resources_box_dropdown]' do
        if active_items[key] == true
          find('.ui-drop-item:not([class*=disabled])', text: I18n.t(text_key))
        else
          find('.ui-drop-item.disabled', text: I18n.t(text_key))
        end
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

  def open_dropdown
    within '[data-test-id=resources_box_dropdown]' do
      find('.dropdown-toggle').click
    end
  end

  def text_keys
    {
      add_to_set: :resources_box_batch_actions_addtoset,
      remove_from_set: :resources_box_batch_actions_removefromset,
      media_entries_metadata: :resources_box_batch_actions_edit,
      collections_metadata: :resources_box_batch_actions_edit_sets,
      media_entries_permissions:
        :resources_box_batch_actions_managepermissions,
      collections_permissions:
        :resources_box_batch_actions_sets_managepermissions,
      media_entries_transfer_responsibility:
        :resources_box_batch_actions_transfer_responsibility_entries,
      collections_transfer_responsibility:
        :resources_box_batch_actions_transfer_responsibility_sets
    }
  end
end
