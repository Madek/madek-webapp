require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'keyword sets fallback' do

  scenario 'entries show fallback' do
    config = create_data(create_config)
    user = default_user(config)
    keyword = resource_by_id(config, :keyword_1)

    login(user)

    visit_keyword_contents(
      keyword,
      type: 'entries',
      list: {
        show_filter: true,
        filter: {
          search: 'Collection'
        }.to_json
      }
    )

    check_set_fallback
  end

  scenario 'entries no fallback when media files filter' do
    config = create_data(create_config)
    user = default_user(config)
    keyword = resource_by_id(config, :keyword_1)

    login(user)

    visit_keyword_contents(
      keyword,
      type: 'entries',
      list: {
        show_filter: true,
        filter: {
          search: 'Collection',
          media_files: [
            {
              key:  'media_type',
              value: 'image'
            }
          ]
        }.to_json
      }
    )

    check_empty_box
  end

  private

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
        type: Collection,
        id: :collection,
        title: 'Collection',
        created_at: 0,
        last_change: 0,
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
