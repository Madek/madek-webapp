require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'search sets fallback' do

  scenario 'entries show fallback' do
    config = create_data(create_config)
    user = default_user(config)

    login(user)

    visit_entries_search_result(
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

    login(user)

    visit_entries_search_result(
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

  def visit_entries_search_result(parameters)
    visit media_entries_path(parameters)
  end

  def create_config
    [
      {
        type: User
      },
      {
        type: Collection,
        id: :collection,
        title: 'Collection',
        created_at: 0,
        last_change: 0
      }
    ]
  end
end
