require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'vocabulary sorting' do

  scenario 'sorting' do
    config = create_data(create_config)
    login_new(config)

    entries_blank(config, 'title ASC')
    collections_blank(config, 'title ASC')
  end

  private

  def entries_blank(config, order)
    vocabulary = resource_by_id(config, :vocabulary_1)
    visit_vocabulary_contents(
      vocabulary,
      type: 'entries',
      list: { show_filter: true, order: order }
    )
    check_content_all_media_entry_titles(config, order)
  end

  def collections_blank(config, order)
    vocabulary = resource_by_id(config, :vocabulary_1)
    visit_vocabulary_contents(
      vocabulary,
      type: 'collections',
      list: { show_filter: true, order: order }
    )
    check_content_all_collection_titles(config, order)
  end

  def visit_vocabulary_contents(vocabulary, parameters)
    visit vocabulary_contents_path(vocabulary, parameters)
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
        data: :text
      },
      {
        type: Vocabulary,
        id: :vocabulary_1,
        meta_keys: [:meta_key_1]
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
            value: 'Text 1'
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
            value: 'Text 1'
          }
        ]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
end
