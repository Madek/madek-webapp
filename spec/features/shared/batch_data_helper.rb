module BatchDataHelper

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
