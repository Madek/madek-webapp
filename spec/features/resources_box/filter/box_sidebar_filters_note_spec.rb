require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'BoxSidebar filters note' do

  scenario 'visible when type is all' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'all', list: { show_filter: 'true' })

    expect(find_resources_box).to have_selector('.filter-panel .mtm')
  end

  scenario 'hidden when type is entries' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'entries', list: { show_filter: 'true' })

    expect(find_resources_box).to have_no_selector('.filter-panel .mtm')
  end

  scenario 'hidden when type is collections' do
    config = create_data(create_config)
    user = default_user(config)
    parent = resource_by_id(config, :parent)

    login(user)

    visit_resource(parent, type: 'collections', list: { show_filter: 'true' })

    expect(find_resources_box).to have_no_selector('.filter-panel .mtm')
  end

  scenario 'hidden on entries index (search results)' do
    config = create_data(create_config)
    user = default_user(config)

    login(user)

    visit media_entries_path(list: { show_filter: 'true' })

    expect(find_resources_box).to have_no_selector('.filter-panel .mtm')
  end

  scenario 'hidden on collections index (search results)' do
    config = create_data(create_config)
    user = default_user(config)

    login(user)

    visit collections_path(list: { show_filter: 'true' })

    expect(find_resources_box).to have_no_selector('.filter-panel .mtm')
  end

  private

  def create_config
    [
      { type: User },
      {
        type: MediaEntry,
        id: :child_entry,
        title: 'Child Entry',
        created_at: 1,
        last_change: 1
      },
      {
        type: Collection,
        id: :child_collection,
        title: 'Child Collection',
        created_at: 2,
        last_change: 2
      },
      {
        type: Collection,
        id: :parent,
        title: 'Parent Collection',
        created_at: 0,
        last_change: 0,
        children: [:child_entry, :child_collection]
      }
    ]
  end
end
