require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'clipboard async loading' do

  scenario 'async loading' do
    config = create_data(create_config)
    login_new(config)

    clipboard_blank(config, 'title ASC')
  end

  private

  def clipboard_blank(config, order)
    visit_clipboard(
      list: {
        order: order
      }
    )
    check_content_by_ids(
      config,
      order,
      all_media_entry_syms + all_collection_syms
    )
  end

  def all_media_entry_syms
    [*100..120].map { |i| "media_entry_#{i}".to_sym }
  end

  def all_collection_syms
    [*100..120].map { |i| "collection_#{i}".to_sym }
  end

  def visit_clipboard(parameters)
    visit my_dashboard_section_path(:clipboard, parameters)
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
        title: "#{i} MediaEntrySearch",
        created_at: i,
        last_change: i,
        meta_data: [],
        clipboard: true
      }
    end \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} CollectionSearch",
        created_at: i,
        last_change: i,
        meta_data: [],
        clipboard: true
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
end
