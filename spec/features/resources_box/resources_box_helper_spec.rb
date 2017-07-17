# rubocop:disable Metrics/ModuleLength
require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../app/infinite_scroll/_shared'

module ResourcesBoxHelper

  private

  def login_new(config)
    login(default_user(config))
  end

  def collection_titles_1
    ['B Collection 3', 'A Collection 2', 'C Collection 1']
  end

  def config_ordered(config, order)
    case order
    when :created_at_asc
      config.sort_by { |entry| entry[:resource].created_at }
    when :created_at_desc
      config.sort_by { |entry| entry[:resource].created_at }.reverse
    when :title
      config.sort_by { |entry| entry[:resource].title }
    when :last_change
      config
      .sort_by { |entry| entry[:resource].edit_session_updated_at }
      .reverse
    else
      throw 'Order unknown: ' + order.to_s
    end
  end

  def list_orders
    ['title ASC', 'created_at ASC', 'created_at DESC', 'last_change']
  end

  def map_order(string_order)
    case string_order
    when 'created_at ASC' then :created_at_asc
    when 'created_at DESC' then :created_at_desc
    when 'last_change' then :last_change
    when 'title ASC' then :title
    else
      throw 'Unexpected order: ' + string_order.to_s
    end
  end

  def all_titles(config, order)
    config_ordered(config, order).map do |entry|
      entry[:resource].title
    end
  end

  def all_resource_ids(config)
    config
    .select do |e|
      e[:type] == MediaEntry || e[:type] == Collection
    end
    .map { |e| e[:id] }
  end

  def media_entry_ids(config)
    config
    .select do |e|
      e[:type] == MediaEntry
    end
    .map { |e| e[:id] }
  end

  def titles_by_ids(config, order, ids)
    config_ordered(
      config.select { |e| ids.include?(e[:id]) },
      order
    ).map { |e| e[:resource].title }
  end

  def media_entry_titles(config, order)
    resources = config.select { |entry| entry[:type] == MediaEntry }
    config_ordered(resources, order).map do |entry|
      entry[:resource].title
    end
  end

  def collection_titles(config, order)
    resources = config.select { |entry| entry[:type] == Collection }
    config_ordered(resources, order).map do |entry|
      entry[:resource].title
    end
  end

  def media_entry_titles_1(order)
    case order
    when :created_at_asc
      ['B Media Entry 1', 'A Media Entry 2', 'C Media Entry 3']
    when :created_at_desc
      ['C Media Entry 3', 'A Media Entry 2', 'B Media Entry 1']
    when :title
      ['A Media Entry 2', 'B Media Entry 1', 'C Media Entry 3']
    when :last_change
      ['B Media Entry 1', 'C Media Entry 3', 'A Media Entry 2']
    else
      throw 'Order unknown: ' + order.to_s
    end
  end

  def create_data(config)
    create_resources_ordered(config)
    force_meta_data_updated_ordered(config)
    append_children(config)
    config
  end

  def default_user(config)
    users = config.select { |e| e[:type] == User }
    if users.length != 1
      throw 'Default user only possible if only one exists.'
    end
    users.first[:resource]
  end

  def resource_by_id(config, id)
    entry_by_id(config, id)[:resource]
  end

  def entry_by_id(config, id)
    config.select { |entry| entry[:id] == id }.first
  end

  def append_children(config)
    config
    .select { |entry| entry[:type] == Collection && entry[:children] }
    .each do |entry|
      entry[:children].each do |child_id|
        child = config.select { |c| c[:id] == child_id }.first
        unless child
          throw 'Cannot find config for child id: ' + child_id.to_s
        end
        parent = entry[:resource]
        parent.send(
          child[:type].name.underscore.pluralize) << child[:resource]
        parent.save
        entry[:resource] = parent.reload
      end
    end
  end

  def create_resources_ordered(config)
    create_users(config)
    create_groups(config)
    create_apis(config)
    create_vocabularies(config)
    create_keywords(config)
    create_resources(config)
    create_meta_data(config)
    add_to_clipboard(config)
    add_users_to_groups(config)
    add_resources_to_groups(config)
    add_resources_to_apis(config)
    add_resources_to_users(config)
  end

  def create_users(config)
    config
    .select { |entry| entry[:type] == User }
    .each do |entry|
      entry[:resource] = create_user
    end
  end

  def create_groups(config)
    config
    .select { |entry| entry[:type] == Group }
    .each do |entry|
      entry[:resource] = create_group
    end
  end

  def create_apis(config)
    config
    .select { |entry| entry[:type] == ApiClient }
    .each do |entry|
      entry[:resource] = create_api
    end
  end

  def create_clipboard_collection_lazy(user)
    clipboard = Collection.unscoped.where(clipboard_user_id: user.id).first
    unless clipboard
      clipboard = Collection.create!(
        get_metadata_and_previews: false,
        responsible_user: user,
        creator: user,
        clipboard_user_id: user.id)
    end
    clipboard
  end

  def add_to_clipboard(config)
    media_entries = config
      .select { |entry| entry[:clipboard] && entry[:type] == MediaEntry }
      .map { |entry| entry[:resource] }

    collections = config
      .select { |entry| entry[:clipboard] && entry[:type] == Collection }
      .map { |entry| entry[:resource] }

    return if media_entries.empty? && collections.empty?

    user = default_user(config)
    clipboard = create_clipboard_collection_lazy(user)

    clipboard.media_entries << media_entries
    clipboard.collections << collections

    clipboard.save
    clipboard.reload
  end

  def create_resources(config)
    config
    .select { |entry| [MediaEntry, Collection].include?(entry[:type]) }
    .sort_by { |entry| entry[:created_at] }.each do |entry|
      underscore = entry[:type].name.underscore

      user =
        if entry[:user]
          resource_by_id(config, entry[:user])
        else
          default_user(config)
        end

      get_metadata_and_previews = (entry[:visibility] != :private)

      resource = send(
        "create_#{underscore}",
        'Initial ' + entry[:title],
        user,
        get_metadata_and_previews)
      entry[:resource] = resource.reload
      sleep 0.01
    end
  end

  def meta_key_data_type(data_type)
    case data_type
    when :text then 'MetaDatum::Text'
    when :keywords then 'MetaDatum::Keywords'
    else
      throw 'Unexpected meta key data type: ' + data_type.to_s
    end
  end

  def meta_key_entry(config, meta_key_sym)
    config
    .select { |e| e[:type] == MetaKey && e[:id] == meta_key_sym }
    .first
  end

  def full_meta_key_id(config, meta_key_sym)
    vocab_id = vocabulary_id(config, meta_key_sym)
    vocab_id + ':' + meta_key_sym.to_s
  end

  def create_keywords(config)
    config
    .select { |e| e[:type] == Keyword }
    .each do |keyword_config|
      keyword = FactoryGirl.create(
        :keyword,
        meta_key_id: full_meta_key_id(config, keyword_config[:meta_key])
      )
      keyword_config[:resource] = keyword
    end
  end

  def create_vocabularies(config)
    config
    .select { |entry| entry[:type] == Vocabulary }
    .each do |entry|
      resource = FactoryGirl.create(:vocabulary, id: entry[:id].to_s)

      entry[:meta_keys].each do |mk|
        meta_key_id = entry[:id].to_s + ':' + mk.to_s
        MetaKey.where(id: meta_key_id).first ||
          FactoryGirl.create(
            :meta_key,
            id: meta_key_id,
            meta_datum_object_type: meta_key_data_type(
              meta_key_entry(config, mk)[:data]))
      end
      entry[:resource] = resource
    end
  end

  def vocabulary_id(config, meta_key_sym)
    vocab = config
      .select { |e| e[:type] == Vocabulary }
      .select do |e|
        !e[:meta_keys].select { |f| f == meta_key_sym }.empty?
      end
      .first

    vocab[:id].to_s
  end

  def create_text_meta_datum(resource, meta_key_id, value)
    FactoryGirl.create(
      :meta_datum_text,
      "#{resource.class.name.underscore}_id" => resource.id,
      meta_key: MetaKey.find(meta_key_id),
      string: value)
  end

  def keyword_entry(config, keyword_sym)
    config
    .select { |e| e[:type] == Keyword && e[:id] == keyword_sym }
    .first
  end

  def create_keywords_meta_datum(config, resource, meta_key_id, keyword_syms)
    keywords = keyword_syms.map do |keyword_sym|
      keyword_entry(config, keyword_sym)[:resource]
    end

    FactoryGirl.create(
      :meta_datum_keywords,
      "#{resource.class.name.underscore}_id" => resource.id,
      meta_key: MetaKey.find(meta_key_id),
      keywords: keywords)
  end

  def create_meta_datum(config, resource_entry, meta_datum_config)
    meta_key_sym = meta_datum_config[:key]
    value = meta_datum_config[:value]

    meta_key_id = vocabulary_id(config, meta_key_sym) + ':' + meta_key_sym.to_s
    resource = resource_entry[:resource]

    meta_key_data_type = meta_key_entry(config, meta_key_sym)[:data]
    case meta_key_data_type
    when :text
      create_text_meta_datum(resource, meta_key_id, value)
    when :keywords
      create_keywords_meta_datum(config, resource, meta_key_id, value)
    else
      throw 'Unexpected meta key data type: ' + meta_key_data_type.to_s
    end
  end

  def create_meta_data(config)
    config
    .select do |entry|
      [MediaEntry, Collection].include?(entry[:type]) && entry[:meta_data]
    end
    .each do |entry|
      entry[:meta_data].each do |md|
        create_meta_datum(config, entry, md)
      end
    end
  end

  def add_users_to_groups(config)
    config
    .select { |entry| entry[:type] == User }
    .each do |entry|
      next unless entry[:groups]

      user = entry[:resource]
      entry[:groups].each do |group_sym|
        group = resource_by_id(config, group_sym)
        group.users << user
        group.save!
        group.reload
      end
    end
  end

  def add_resources_to_groups(config)
    add_resources_permission(config, :groups)
  end

  def add_resources_to_apis(config)
    add_resources_permission(config, :apis)
  end

  def add_resources_to_users(config)
    add_resources_permission(config, :users)
  end

  def add_resources_permission(config, permission_type)
    config
    .select { |entry| [MediaEntry, Collection].include?(entry[:type]) }
    .each do |entry|
      next unless entry[permission_type]

      resource = entry[:resource]
      entry[permission_type].each do |group_sym|
        permission_target = resource_by_id(config, group_sym)

        if permission_type == :groups
          add_group_permission(resource, permission_target)
        elsif permission_type == :apis
          add_api_client_permission(resource, permission_target)
        elsif permission_type == :users
          add_user_permission(resource, permission_target)
        else
          throw 'Unexpected permission: ' + permission_type.to_s
        end
      end
    end
  end

  def add_group_permission(resource, group)
    underscore = resource.class.name.underscore
    FactoryGirl.create(
      "#{underscore}_group_permission".to_sym,
      get_metadata_and_previews: true,
      group: group,
      underscore => resource)
  end

  def add_api_client_permission(resource, api_client)
    underscore = resource.class.name.underscore
    FactoryGirl.create(
      "#{underscore}_api_client_permission".to_sym,
      get_metadata_and_previews: true,
      api_client: api_client,
      underscore => resource)
  end

  def add_user_permission(resource, user)
    underscore = resource.class.name.underscore
    FactoryGirl.create(
      "#{underscore}_user_permission".to_sym,
      get_metadata_and_previews: true,
      user: user,
      underscore => resource)
  end

  def force_meta_data_updated_ordered(config)
    config
    .select { |entry| [MediaEntry, Collection].include?(entry[:type]) }
    .sort_by { |entry| entry[:last_change] }.each do |entry|
      resource = entry[:resource]
      title_data = resource.meta_data.find_by(meta_key_id: 'madek_core:title')
      title_data.string = entry[:title]
      title_data.save
      entry[:resource] = resource.reload
      sleep 0.01
    end
  end

  def all_titles_1
    collection_titles_1 + media_entry_titles_1(:created_at_desc)
  end

  def set_last_change(resource, year)
    resource.edit_session_updated_at = Date.new(year, 1, 1)
    resource.save
    resource.reload
  end

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

  def find_section(name)
    find_resources_box.find('.ui-side-filter-list').find(
      :xpath,
      ".//li[contains(@class, 'ui-side-filter-lvl1-item')]" \
      "[.//a[contains(., '#{name}')]]")
  end

  def find_sub_section(section_el, name)
    section_el.find(
      :xpath,
      ".//li[contains(@class, 'ui-side-filter-lvl2-item')]" \
      "[.//a[contains(., '#{name}')]]")
  end

  def find_filter(sub_section_el, name)
    sub_section_el.find(
      :xpath,
      ".//li[contains(@class, 'ui-side-filter-lvl3-item')]" \
      "[.//a[contains(., '#{name}')]]")
  end

  def open_dynamic_filter(section, sub_section)
    section_el = find_section(section)
    section_el.click
    sub_section_el = find_sub_section(section_el, sub_section)
    sub_section_el.click
  end

  def check_dynamic_filter(section, sub_section, filter, count)
    section_el = find_section(section)
    sub_section_el = find_sub_section(section_el, sub_section)
    filter_el = find_filter(sub_section_el, filter)
    filter_el.find('.ui-lvl3-item-count', text: count.to_s)
  end

  def check_content_by_ids(config, order, ids)
    check_content(
      titles_by_ids(
        config,
        map_order(order),
        ids
      )
    )
  end

  def check_content_all_media_entry_titles(config, order)
    check_content(media_entry_titles(config, map_order(order)))
  end

  def check_content_all_collection_titles(config, order)
    check_content(collection_titles(config, map_order(order)))
  end

  def check_content(titles)
    count = 0
    loop do
      scroll_to_end_of_last_page
      resources = find_resources_box.all('.ui-resource')
      break if (resources.length == titles.length || count > 10)
      count += 1
      sleep 1
    end

    resources = find_resources_box.all('.ui-resource')
    expect(resources.length).to eq(titles.length)

    pairs = titles.zip(resources)

    pairs.each do |pair|
      title = pair[0]
      resource = pair[1]
      Rails.logger.info(title + ' - ' + resource.text)
      resource.find('.ui-thumbnail-meta-title', text: title)
    end
  end

  def check_set_fallback
    fallback_text = I18n.t(:resources_box_no_content_but_sets_1) \
      + I18n.t(:resources_box_no_content_but_sets_2) \
      + I18n.t(:resources_box_no_content_but_sets_3)
    find_resources_box.find(
      'div.title-l', text: fallback_text)
  end

  def check_empty_box
    find_resources_box.find(
      'div.title-l', text: I18n.t(:resources_box_no_content))
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

  def check_side_filter(state)
    if state == :invisible
      expect(find_resources_box).to have_no_selector(
        'div.ui-side-filter')
    elsif state == :only_search || state == :full
      side_filter = find_resources_box.find('div.ui-side-filter')
      expect(side_filter).to have_selector('div.ui-side-filter-search')
      if state == :full
        side_filter.find('ul.ui-side-filter-list')
      else
        expect(side_filter).to have_no_selector(
          'ul.ui-side-filter-list')
      end
    else
      throw 'Unexpected state: ' + state.to_s
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

  def check_switcher_link(switcher_sym, parameters)
    href = find_switcher.find('a', text: switcher_texts[switcher_sym])[:href]
    uri = URI(href)
    actual = Rack::Utils.parse_nested_query(uri.query)
    expect(actual.deep_symbolize_keys).to eq(parameters.deep_symbolize_keys)
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
      expect(uri.path).to eq(resource_path(resource, {}))
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

  def resource_path(resource, parameters)
    self.send("#{resource.class.name.underscore}_path", resource, parameters)
  end

  def visit_resource(resource, parameters)
    visit resource_path(resource, parameters)
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

  def create_group
    FactoryGirl.create(:group)
  end

  def create_api
    FactoryGirl.create(:api_client)
  end

  def create_collection(title, user, get_metadata_and_previews)
    collection = Collection.create!(
      get_metadata_and_previews: get_metadata_and_previews,
      responsible_user: user,
      creator: user)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: user)
    collection
  end

  def create_media_entry(title, user, get_metadata_and_previews)
    media_entry = FactoryGirl.create(
      :media_entry,
      get_metadata_and_previews: get_metadata_and_previews,
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
# rubocop:enable Metrics/ModuleLength
