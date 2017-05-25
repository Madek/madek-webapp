require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'set sorting' do

  scenario 'collection with children 5' do
    config = create_data(create_config)
    login_new(config)

    list_orders.each { |order| all_blank(config, order) }
    list_orders.each { |order| all_textsearch(config, order) }
    list_orders.each { |order| entries_blank(config, order) }
    list_orders.each { |order| entries_textsearch(config, order) }
    list_orders.each { |order| entries_filesearch(config, order) }
    list_orders.each { |order| collections_blank(config, order) }
    list_orders.each { |order| collections_textsearch(config, order) }
  end

  private

  def all_blank(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'all',
      list: { show_filter: true, order: order }
    )
    check_content_by_ids(
      config,
      order,
      [:media_entry_1, :media_entry_2, :media_entry_3, :media_entry_nf] +
        [:collection_1, :collection_2, :collection_3, :collection_nf]
    )
  end

  def all_textsearch(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'all',
      list: {
        show_filter: true,
        order: order,
        filter: {
          search: 'AAA'
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      order,
      [:media_entry_2, :media_entry_nf, :collection_2, :collection_nf])
  end

  def entries_blank(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'entries',
      list: { show_filter: true, order: order }
    )
    check_content_all_media_entry_titles(config, order)
  end

  def entries_textsearch(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: true,
        order: order,
        filter: {
          search: 'media entry'
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      order,
      [:media_entry_1, :media_entry_2, :media_entry_3])
  end

  def entries_filesearch(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'entries',
      list: {
        show_filter: true,
        order: order,
        filter: {
          media_files: [
            {
              key: 'filename',
              value: 'grumpy'
            }
          ]
        }.to_json
      }
    )
    check_content_all_media_entry_titles(config, order)
  end

  def collections_blank(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'collections',
      list: { show_filter: true, order: order }
    )
    check_content_only_child_collections(config, order)
  end

  def collections_textsearch(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'collections',
      list: {
        show_filter: true,
        order: order,
        filter: {
          search: 'collection'
        }.to_json
      }
    )
    check_content_by_ids(
      config,
      order,
      [:collection_1, :collection_2, :collection_3])
  end

  def check_content_only_child_collections(config, order)
    check_content(
      titles_by_ids(
        config,
        map_order(order),
        [:collection_1, :collection_2, :collection_3, :collection_nf]
      )
    )
  end

  # rubocop:disable Metrics/MethodLength
  def create_config
    [
      {
        type: User
      },
      {
        type: MediaEntry,
        id: :media_entry_1,
        title: 'BBB Media Entry',
        created_at: 1,
        last_change: 3
      },
      {
        type: MediaEntry,
        id: :media_entry_2,
        title: 'AAA Media Entry',
        created_at: 2,
        last_change: 1
      },
      {
        type: MediaEntry,
        id: :media_entry_3,
        title: 'CCC Media Entry',
        created_at: 3,
        last_change: 2
      },
      {
        type: MediaEntry,
        id: :media_entry_nf,
        title: 'AAA AAA NOT FOUND',
        created_at: 4,
        last_change: 4
      },
      {
        type: Collection,
        id: :collection_1,
        title: 'BBB Collection',
        created_at: 1 + 4,
        last_change: 3 + 4
      },
      {
        type: Collection,
        id: :collection_2,
        title: 'AAA Collection',
        created_at: 2 + 4,
        last_change: 1 + 4
      },
      {
        type: Collection,
        id: :collection_3,
        title: 'CCC Collection',
        created_at: 3 + 4,
        last_change: 2 + 4
      },
      {
        type: Collection,
        id: :collection_nf,
        title: 'AAA BBB NOT FOUND',
        created_at: 4 + 4,
        last_change: 4 + 4
      },
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        created_at: 0,
        last_change: 0,
        children: [] +
          [:media_entry_1, :media_entry_2, :media_entry_3] +
          [:collection_1, :collection_2, :collection_3] +
          [:media_entry_nf, :collection_nf]
      }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
