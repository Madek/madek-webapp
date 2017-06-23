require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'keyword switcher' do

  scenario 'from entries' do
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
          search: '100 Media Entry',
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
      :entries,
      type: 'entries',
      list: {
        show_filter: 'true',
        filter: {
          'search': '100 Media Entry',
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
          'search': '100 Media Entry'
        }.to_json
      }
    )
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
      }
    ] \
    + [*100..120].map do |i|
      {
        type: MediaEntry,
        id: "media_entry_#{i}".to_sym,
        title: "#{i} Media Entry",
        created_at: i,
        last_change: i,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      }
    end \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} Collection",
        created_at: i,
        last_change: i,
        meta_data: [
          {
            key: :meta_key_1,
            value: [:keyword_1]
          }
        ]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
end
