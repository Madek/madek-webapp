require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'resource box' do

  scenario 'empty collection' do
    user = create_user
    parent = create_collection('Parent', user)
    login(user)
    visit_resource(parent)

    check_empty_box(false)
    check_switcher_triple(:all, parent)
    check_filter_button(:active)
    check_side_filter(false)

    click_switcher(:entries)

    check_empty_box(false)
    check_switcher_triple(:entries, parent)
    check_filter_button(:active)
    check_side_filter(false)

    click_switcher(:collections)

    check_empty_box(false)
    check_switcher_triple(:collections, parent)
    check_filter_button(:active)
    check_side_filter(false)

    click_switcher(:entries)
    click_filter_button

    check_filter_button(:inactive)
    check_side_search(true)
    check_side_filter(false)
  end

  scenario 'collection with children' do
    user = create_user
    parent = create_collection('Parent', user)
    media_entry_1 = create_media_entry('Media Entry 1', user)
    media_entry_2 = create_media_entry('Media Entry 2', user)
    collection_1 = create_collection('Collection 1', user)
    collection_2 = create_collection('Collection 2', user)
    parent.media_entries << media_entry_1
    parent.media_entries << media_entry_2
    parent.collections << collection_1
    parent.collections << collection_2

    keyword_1 = create_keyword(user, 'Keyword 1')
    keyword_2 = create_keyword(user, 'Keyword 2')
    append_keywords(user, media_entry_1, [keyword_1, keyword_2])

    login(user)
    visit_resource(parent)

    collection_titles = ['Collection 2', 'Collection 1']
    media_entry_titles = ['Media Entry 2', 'Media Entry 1']
    all_titles = collection_titles + media_entry_titles

    check_content(all_titles)
    check_switcher_triple(:all, parent)
    check_filter_button(:active)
    check_side_filter(false)

    click_switcher(:entries)

    check_content(media_entry_titles)
    check_switcher_triple(:entries, parent)
    check_filter_button(:active)
    check_side_filter(false)

    click_filter_button

    do_side_search('Media Entry 1')
    select_keyword_filter(keyword_1)
    check_content(['Media Entry 1'])
    check_switcher_triple(:entries, parent)
    check_filter_button(:inactive)
    check_side_filter(true)

    click_switcher(:collections)
    check_filter_button(:inactive)
    check_side_filter(false)
    check_search_input('Media Entry 1')
  end

  private

  def select_keyword_filter(keyword)
    context = Context.find('core')
    section_label = context.label
    context_key = context.context_keys.where(
      meta_key_id: 'madek_core:keywords').first
    sub_section_label = context_key.label
    find('li.ui-side-filter-lvl1-item', text: section_label).click
    find('li.ui-side-filter-lvl2-item', text: sub_section_label).click
    find('li.ui-side-filter-lvl3-item', text: keyword.term).click
  end

  def create_keyword(user, term)
    meta_key = MetaKey.find('madek_core:keywords')
    FactoryGirl.create(:keyword, meta_key: meta_key, term: term, creator: user)
  end

  def append_keywords(user, resource, keywords)
    MetaDatum::Keywords.create_with_user!(
      user,
      media_entry: resource,
      created_by: user,
      meta_key_id: 'madek_core:keywords',
      value: keywords)
  end

  def do_side_search(term)
    input = find('input.ui-filter-search-input')
    input.click
    input.set(term)
    input.native.send_keys(:return)
  end

  def check_search_input(term)
    input = find('input.ui-filter-search-input')
    expect(input.value).to eq(term)
  end

  def check_content(titles)
    resources = find_resources_box.all('.ui-resource')

    expect(resources.length).to eq(titles.length)

    pairs = titles.zip(resources)

    pairs.each do |pair|
      title = pair[0]
      resource = pair[1]
      resource.find('.ui-thumbnail-meta-title', text: title)
    end
  end

  def check_empty_box(show_set_fallback)
    if show_set_fallback
      throw 'not implemented'
    else
      find_resources_box.find(
        'div.title-l', text: I18n.t(:resources_box_no_content))
    end
  end

  def find_resources_box
    find('div[data-test-id=resources-box]')
  end

  def find_filter_button
    find_resources_box.find('.button[data-test-id=filter-button]')
  end

  def check_side_search(visible)
    if visible
      expect(find_resources_box).to have_selector(
        '.ui-side-filter-search')
    else
      expect(find_resources_box).to have_no_selector(
        '.ui-side-filter-search')
    end
  end

  def check_side_filter(visible)
    if visible
      expect(find_resources_box).to have_selector(
        'ul[data-test-id=side-filter]')
    else
      expect(find_resources_box).to have_no_selector(
        'ul[data-test-id=side-filter]')
    end
  end

  def click_filter_button
    find_resources_box.find('.button[data-test-id=filter-button]').click
  end

  def check_filter_button(state)
    case state
    when :hidden
      expect(find_resources_box).to have_no_selector(
        '.button[data-test-id=filter-button]')
    when :inactive
      expect(find_resources_box).to have_selector(
        '.button.active[data-test-id=filter-button]')
    when :active
      expect(find_resources_box).to have_selector(
        '.button[data-test-id=filter-button]')
    else
      throw 'Filter state unexpected: ' + state.to_s
    end
  end

  def check_switcher_triple(active, parent)
    check_switcher_generic([:all, :entries, :collections], active, parent)
  end

  def check_switcher_double(active, parent)
    check_switcher_generic([:entries, :collections], active, parent)
  end

  def click_switcher(switcher)
    find_switcher.find('.button', text: switcher_texts[switcher]).click
  end

  def switcher_texts
    {
      all: 'Alle',
      entries: I18n.t('sitemap_entries'),
      collections: I18n.t('sitemap_collections')
    }
  end

  def find_switcher
    find_resources_box.find('div[data-test-id=resource-type-switcher]')
  end

  def check_switcher_generic(buttons, active, resource)
    group = find_switcher
    expect(group).to have_selector('.button', count: buttons.length)

    buttons.each do |button|
      text = switcher_texts[button]
      expect(group).to have_selector('.button', text: text)
      if button == active
        expect(group).to have_selector('.active', text: text)
      else
        expect(group).to have_no_css('.active', text: text)
      end

      next if button == active

      a = group.find('a', text: text)
      uri = URI(a[:href])
      expect(uri.path).to eq(resource_path(resource))
      params = Rack::Utils.parse_query(uri.query)
      check_params(params, button)
    end
  end

  def check_params(params, button)
    check_type(params, button)
    check_page(params)
    check_filter(params)
    check_accordion(params)
  end

  def check_type(params, button)
    expect(params['type']).to eq(button.to_s)
  end

  def check_page(params)
    if params['list[page]']
      expect(params['list[page]']).to eq('1')
    end
  end

  def check_filter(params)
    if params['list[filter]']
      filter = JSON.parse(params['list[filter]'])
      if filter['search']
        expect(filter.size).to eq(1)
      else
        expect(filter.size).to eq(0)
      end
    end
  end

  def check_accordion(params)
    if params['list[accordion]']
      accordion = JSON.parse(params['list[accordion]'])
      expect(accordion.size).to eq(0)
    end
  end

  def resource_path(resource)
    self.send("#{resource.class.name.underscore}_path", resource)
  end

  def visit_resource(resource)
    visit resource_path(resource)
  end

  def visit_dashboard
    visit my_dashboard_path
  end

  def login(user)
    sign_in_as user
  end

  def create_user
    person = FactoryGirl.create(:person)
    FactoryGirl.create(
      :user,
      person: person
    )
  end

  def create_collection(title, user)
    collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: user,
      creator: user)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: user)
    collection
  end

  def create_media_entry(title, user)
    media_entry = FactoryGirl.create(
      :media_entry,
      get_metadata_and_previews: true,
      responsible_user: user,
      creator: user)
    FactoryGirl.create(
      :media_file_for_image,
      media_entry: media_entry)
    MetaDatum::Text.create!(
      media_entry: media_entry,
      string: title,
      meta_key: meta_key_title,
      created_by: user)
    media_entry
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end
end
