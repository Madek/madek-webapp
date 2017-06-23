require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'group sets fallback' do

  scenario 'entries show fallback' do
    config = create_data(create_config)
    user = default_user(config)
    group = resource_by_id(config, :group_1)

    login(user)

    visit_group(
      group,
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
    group = resource_by_id(config, :group_1)

    login(user)

    visit_group(
      group,
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

  def visit_group(group, parameters)
    visit my_group_path(group, parameters)
  end

  def create_config
    [
      {
        type: User,
        groups: [:group_1]
      },
      {
        type: Group,
        id: :group_1
      },
      {
        type: Collection,
        id: :collection,
        title: 'Collection',
        created_at: 0,
        last_change: 0,
        groups: [:group_1]
      }
    ]
  end
end
