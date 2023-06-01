require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'set switcher' do

  scenario 'from all (default)' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)
    keyword = resource_by_id(config, :keyword_1)

    login(user)

    visit_resource(
      parent,
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

    check_switcher_link(
      :all,
      list: {
        show_filter: 'true',
        filter: {
          'search': 'Media Entry 1',
           meta_data: [
             {
               key: keyword.meta_key_id,
               value: keyword.id
             }
           ]
        }.to_json
      }
    )

    check_switcher_link(
      :entries,
      type: 'entries',
      list: {
        show_filter: 'true',
        page: '1',
        filter: {
          'search': 'Media Entry 1'
        }.to_json
      }
    )

    check_switcher_link(
      :collections,
      type: 'collections',
      list: {
        show_filter: 'true',
        page: '1',
        filter: {
          'search': 'Media Entry 1'
        }.to_json
      }
    )

  end

  scenario 'from entries' do
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
          ],
          media_files: [
            {
              key:  'media_type',
              value: 'image'
            }
          ],
          permissions: [
            key: 'visibility',
            value: 'public'
          ]
        }.to_json
      }
    )

    check_switcher_link(
      :all,
      type: 'all',
      list: {
        show_filter: 'true',
        page: '1',
        filter: {
          'search': 'Media Entry 1'
        }.to_json
      }
    )

    check_switcher_link(
      :entries,
      type: 'entries',
      list: {
        show_filter: 'true',
        filter: {
          'search': 'Media Entry 1',
          meta_data: [
            {
              key: keyword.meta_key_id,
              value: keyword.id
            }
          ],
          media_files: [
            {
              key:  'media_type',
              value: 'image'
            }
          ],
          permissions: [
            key: 'visibility',
            value: 'public'
          ]
        }.to_json
      }
    )

    check_switcher_link(
      :collections,
      type: 'collections',
      list: {
        show_filter: 'true',
        page: '1',
        filter: {
          'search': 'Media Entry 1'
        }.to_json
      }
    )
  end

  scenario 'from sets' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)
    keyword = resource_by_id(config, :keyword_1)

    login(user)

    visit_resource(
      parent,
      type: 'collections',
      list: {
        show_filter: true,
        filter: {
          search: 'Collection 1',
          meta_data: [
            {
              key: keyword.meta_key_id,
              value: keyword.id
            }
          ],
          permissions: [
            key: 'visibility',
            value: 'public'
          ]
        }.to_json
      }
    )

    check_switcher_link(
      :all,
      type: 'all',
      list: {
        show_filter: 'true',
        page: '1',
        filter: {
          'search': 'Collection 1'
        }.to_json
      }
    )

    check_switcher_link(
      :entries,
      type: 'entries',
      list: {
        show_filter: 'true',
        page: '1',
        filter: {
          'search': 'Collection 1'
        }.to_json
      }
    )

    check_switcher_link(
      :collections,
      type: 'collections',
      list: {
        show_filter: 'true',
        filter: {
          'search': 'Collection 1',
          meta_data: [
            {
              key: keyword.meta_key_id,
              value: keyword.id
            }
          ],
          permissions: [
            key: 'visibility',
            value: 'public'
          ]
        }.to_json
      }
    )
  end

  private

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
