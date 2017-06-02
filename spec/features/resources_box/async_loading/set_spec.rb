require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'set async loading' do

  scenario 'async loading' do
    config = create_data(create_config)
    login_new(config)

    all_blank(config, 'title ASC')
    entries_blank(config, 'title ASC')
    collections_blank(config, 'title ASC')
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
      all_media_entry_syms + all_collection_syms
    )
  end

  def entries_blank(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'entries',
      list: { show_filter: true, order: order }
    )
    check_content_by_ids(
      config,
      order,
      all_media_entry_syms
    )
  end

  def collections_blank(config, order)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: 'collections',
      list: { show_filter: true, order: order }
    )
    check_content_by_ids(
      config,
      order,
      all_collection_syms
    )
  end

  def all_media_entry_syms
    [*100..120].map { |i| "media_entry_#{i}".to_sym }
  end

  def all_collection_syms
    [*100..120].map { |i| "collection_#{i}".to_sym }
  end

  # rubocop:disable Metrics/MethodLength
  def create_config
    [
      {
        type: User
      }
    ] \
    + [*100..120].map do |i|
      {
        type: MediaEntry,
        id: "media_entry_#{i}".to_sym,
        title: "#{i} Media Entry",
        created_at: i,
        last_change: i
      }
    end \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} Collection",
        created_at: i,
        last_change: i
      }
    end \
    + [
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        created_at: 0,
        last_change: 0,
        children: all_media_entry_syms + all_collection_syms
      }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
