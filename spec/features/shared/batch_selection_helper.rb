module BatchSelectionHelper

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
      media_entries_permissions: :resources_box_batch_actions_managepermissions
    }
  end

  def all_resources
    media_entries_1_2_3.concat(collections_1_2_3)
  end

  def mixed_1_3_1_3
    media_entries_1_3.concat(collections_1_3)
  end

  def media_entries_1_2_3
    [@media_entry_1, @media_entry_2, @media_entry_3]
  end

  def media_entries_1_3
    [@media_entry_1, @media_entry_3]
  end

  def collections_1_2_3
    [@collection_1, @collection_2, @collection_3]
  end

  def collections_1_3
    [@collection_1, @collection_3]
  end

  def prepare_data
    @parent_collection = create_collection('Parent Collection')
    @collection_1 = create_collection('Collection 1')
    @collection_2 = create_collection('Collection 2')
    @collection_3 = create_collection('Collection 3')
    @media_entry_1 = create_media_entry('Media Entry 1')
    @media_entry_2 = create_media_entry('Media Entry 2')
    @media_entry_3 = create_media_entry('Media Entry 3')
    @collection_1.parent_collections << @parent_collection
    @collection_2.parent_collections << @parent_collection
    @collection_3.parent_collections << @parent_collection
    @media_entry_1.parent_collections << @parent_collection
    @media_entry_2.parent_collections << @parent_collection
    @media_entry_3.parent_collections << @parent_collection
  end
end
