require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'search async loading' do

  scenario 'async loading' do
    config = create_data(create_config)
    login_new(config)

    entries_blank(config, 'title ASC')
    collections_blank(config, 'title ASC')
  end

  private

  def entries_blank(config, order)
    visit_entries_search_result(
      list: {
        filter: {
          search: 'MediaEntrySearch'
        }.to_json,
        show_filter: true,
        order: order
      }
    )
    check_content_all_media_entry_titles(config, order)
  end

  def collections_blank(config, order)
    visit_collections_search_result(
      list: {
        filter: {
          search: 'CollectionSearch'
        }.to_json,
        show_filter: true,
        order: order
      }
    )
    check_content_all_collection_titles(config, order)
  end

  def visit_entries_search_result(parameters)
    visit media_entries_path(parameters)
  end

  def visit_collections_search_result(parameters)
    visit collections_path(parameters)
  end

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
        title: "#{i} MediaEntrySearch",
        created_at: i,
        last_change: i,
        meta_data: []
      }
    end \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} CollectionSearch",
        created_at: i,
        last_change: i,
        meta_data: []
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
end
