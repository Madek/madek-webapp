require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'set show box' do

  scenario 'empty collection all' do
    config = create_data(create_empty_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, {})

    check_empty_box
    check_switcher_triple(:all, parent)
    check_filter_button(:active)
    check_side_filter(false)
  end

  scenario 'empty collection entries' do
    config = create_data(create_empty_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'entries')

    check_empty_box
    check_switcher_triple(:entries, parent)
    check_filter_button(:active)
    check_side_filter(false)
  end

  scenario 'empty collection collections' do
    config = create_data(create_empty_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'collections')

    check_empty_box
    check_switcher_triple(:collections, parent)
    check_filter_button(:active)
    check_side_filter(false)
  end

  scenario 'empty collection entries with filter' do
    config = create_data(create_empty_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'entries', list: { show_filter: 'true' })

    check_filter_button(:inactive)
    check_side_search(true)
    check_side_filter(false)
  end

  scenario 'collection with children all' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, {})

    check_content_by_ids(
      config,
      'created_at DESC',
      all_resource_ids(config) - [:parent])
    check_switcher_triple(:all, parent)
    check_filter_button(:active)
    check_side_filter(false)
  end

  scenario 'collection with children entries' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'entries')

    check_content_by_ids(
      config,
      'created_at DESC',
      media_entry_ids(config))
    check_switcher_triple(:entries, parent)
    check_filter_button(:active)
    check_side_filter(false)
  end

  scenario 'collection with children entries search and keyword filter' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)
    keyword = resource_by_id(config, :keyword_1)

    login(user)

    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: true,
        filter: {
          search: 'Media Entry 1',
          meta_data: [
            {
              key: keyword.meta_key_id,
              value: keyword.id
            }
          ]
        }.to_json
      }
    )

    check_content(['Media Entry 1'])
    check_switcher_triple(:entries, parent)
    check_filter_button(:inactive)
    check_side_filter(true)
  end

  scenario 'collection with children collections search filter' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(
      parent,
      type: 'collections',
      list: {
        show_filter: true,
        filter: {
          search: 'Media Entry 1'
        }.to_json
      }
    )

    check_filter_button(:inactive)
    check_side_filter(false)
    check_search_input('Media Entry 1')
  end

  private

  def create_empty_config
    [
      {
        type: User
      },
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        created_at: 0,
        last_change: 0,
        children: []
      }
    ]
  end

  # rubocop:disable Metrics/MethodLength
  def create_config
    [
      {
        type: User
      },
      {
        type: MetaKey,
        id: :meta_key_1,
        data: :keywords
      },
      {
        type: Vocabulary,
        id: :vocabulary_1,
        meta_keys: [:meta_key_1]
      },
      {
        type: Keyword,
        id: :keyword_1,
        meta_key: :meta_key_1
      },
      {
        type: Keyword,
        id: :keyword_2,
        meta_key: :meta_key_1
      },
      {
        type: MediaEntry,
        id: :media_entry_1,
        title: 'B Media Entry 1',
        created_at: 1,
        last_change: 1,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1, :keyword_2]
          }
        ]
      },
      {
        type: MediaEntry,
        id: :media_entry_2,
        title: 'A Media Entry 2',
        created_at: 2,
        last_change: 2
      },
      {
        type: MediaEntry,
        id: :media_entry_3,
        title: 'C Media Entry 3',
        created_at: 3,
        last_change: 3
      },
      {
        type: Collection,
        id: :collection_1,
        title: 'C Collection 1',
        created_at: 1,
        last_change: 1
      },
      {
        type: Collection,
        id: :collection_2,
        title: 'A Collection 2',
        created_at: 2,
        last_change: 2
      },
      {
        type: Collection,
        id: :collection_3,
        title: 'B Collection 3',
        created_at: 3,
        last_change: 3
      },
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        created_at: 0,
        last_change: 0,
        children: [] +
          [:media_entry_1, :media_entry_2, :media_entry_3] +
          [:collection_1, :collection_2, :collection_3]
      }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
