require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'relations async loading' do

  scenario 'async loading parents' do
    config = create_data(create_parents_config)
    login_new(config)

    parents_blank(config, 'title ASC')
  end

  scenario 'async loading siblings' do
    config = create_data(create_siblings_config)
    login_new(config)

    siblings_blank(config, 'title ASC')
  end

  private

  def parents_blank(config, order)
    visit relation_parents_media_entry_path(
      resource_by_id(config, :media_entry),
      list: {
        order: order
      }
    )
    check_content_by_ids(
      config,
      order,
      all_collection_syms
    )
  end

  def siblings_blank(config, order)
    visit relation_siblings_collection_path(
      resource_by_id(config, :collection),
      list: {
        order: order
      }
    )
    check_content_by_ids(
      config,
      order,
      all_collection_syms
    )
  end

  def all_collection_syms
    [*100..120].map { |i| "collection_#{i}".to_sym }
  end

  # rubocop:disable Metrics/MethodLength
  def create_parents_config
    [
      {
        type: User
      },
      {
        type: MediaEntry,
        id: :media_entry,
        title: 'Media Entry',
        created_at: 0,
        last_change: 0
      }
    ] \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} Collection",
        created_at: i,
        last_change: i,
        children: [:media_entry]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def create_siblings_config
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
      },
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        created_at: 0,
        last_change: 0,
        children: [
          :collection
        ] + [*100..120].map { |i| "collection_#{i}".to_sym }
      }
    ] \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} Collection",
        created_at: i,
        last_change: i
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
end
