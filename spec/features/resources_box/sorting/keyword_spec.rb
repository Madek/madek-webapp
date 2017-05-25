require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'keyword sorting' do

  scenario 'sorting' do
    config = create_data(create_config)
    login_new(config)

    list_orders.each { |order| entries_blank(config, order) }
    list_orders.each { |order| collections_blank(config, order) }
  end

  private

  def entries_blank(config, order)
    keyword = resource_by_id(config, :keyword_1)
    visit_keyword_contents(
      keyword,
      type: 'entries',
      list: { show_filter: true, order: order }
    )

    check_content_all_media_entry_titles(config, order)
  end

  def collections_blank(config, order)
    keyword = resource_by_id(config, :keyword_1)
    visit_keyword_contents(
      keyword,
      type: 'collections',
      list: { show_filter: true, order: order }
    )
    check_content_all_collection_titles(config, order)
  end

  def visit_keyword_contents(keyword, parameters)
    visit vocabulary_meta_key_term_show_path(keyword, parameters)
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
        type: MediaEntry,
        id: :media_entry_1,
        title: 'B Media Entry',
        created_at: 1,
        last_change: 3,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      },
      {
        type: MediaEntry,
        id: :media_entry_2,
        title: 'A Media Entry',
        created_at: 2,
        last_change: 1,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      },
      {
        type: MediaEntry,
        id: :media_entry_3,
        title: 'C Media Entry',
        created_at: 3,
        last_change: 2,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      },
      {
        type: Collection,
        id: :collection_1,
        title: 'B Collection',
        created_at: 1,
        last_change: 3,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      },
      {
        type: Collection,
        id: :collection_2,
        title: 'A Collection',
        created_at: 2,
        last_change: 1,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      },
      {
        type: Collection,
        id: :collection_3,
        title: 'C Collection',
        created_at: 3,
        last_change: 2,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
