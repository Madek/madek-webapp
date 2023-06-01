require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

feature 'collection default resource type filter' do

  scenario 'automatic default is "all" when collection contains both entries and collections' do
    config = create_data(create_config)
    user = default_user(config)

    login(user)

    zoo = resource_by_id(config, :zoo_of_all)
    visit_resource(zoo, nil)

    check_switcher_active(:all)
  end


  scenario 'automatic default is "entries" when collection contains entries only' do
    config = create_data(create_config)
    user = default_user(config)
    login(user)

    zoo = resource_by_id(config, :zoo_of_animals)
    visit_resource(zoo, nil)

    check_switcher_active(:entries)
  end

  scenario 'automatic default is "collections" when collection contains collections only' do
    config = create_data(create_config)
    user = default_user(config)
    login(user)

    zoo = resource_by_id(config, :zoo_of_zoos)
    visit_resource(zoo, nil)

    check_switcher_active(:collections)
  end

  scenario 'saving default resource type setting' do
    config = create_data(create_config)
    user = default_user(config)
    login(user)

    zoo = resource_by_id(config, :zoo_of_all)
    visit_resource(zoo, nil)
    expect_disabled_save_button

    # set default to :entries
    click_switcher(:entries)
    expect_enabled_save_button
    click_save_button
    expect_disabled_save_button
    visit_resource(zoo, nil)
    check_switcher_active(:entries)

    # set default to :collections
    click_switcher(:collections)
    expect_enabled_save_button
    click_save_button
    expect_disabled_save_button
    visit_resource(zoo, nil)
    check_switcher_active(:collections)

    # set default to :all
    click_switcher(:all)
    expect_enabled_save_button
    click_save_button
    expect_disabled_save_button
    visit_resource(zoo, nil)
    check_switcher_active(:all)
  end
  
  scenario 'saving default resource type setting (when collection has entries only)' do
    config = create_data(create_config)
    user = default_user(config)
    login(user)

    zoo = resource_by_id(config, :zoo_of_animals)
    visit_resource(zoo, nil)
    expect_disabled_save_button

    # set default to :collections (a bit silly because there is nothing to see)
    click_switcher(:collections)
    expect_enabled_save_button
    click_save_button
    expect_disabled_save_button
    visit_resource(zoo, nil)
    check_switcher_active(:collections)
    
    # set default to :entries (also silly because it is the default anyway)
    click_switcher(:entries)
    expect_enabled_save_button
    click_save_button
    expect_disabled_save_button
    visit_resource(zoo, nil)
    check_switcher_active(:entries)

    # set default to :all (will restore the automatic default)
    click_switcher(:all)
    expect_enabled_save_button
    click_save_button
    expect_disabled_save_button
    visit_resource(zoo, nil)
    check_switcher_active(:entries)
  end

  def expect_enabled_save_button
    within('.ui-polybox') do
      expect(page).to have_css('a:not([disabled])', text: I18n.t(:collection_layout_save))
    end
  end

  def expect_disabled_save_button
    within('.ui-polybox') do
      expect(page).to have_css('a[disabled]', text: I18n.t(:collection_layout_saved))
    end
  end

  def click_save_button
    within('.ui-polybox') do
      find('a', text: I18n.t(:collection_layout_save)).click
    end
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
        data: :keywords
      },
      {
        type: Vocabulary,
        id: :vocabulary_1,
        meta_keys: [:meta_key_1]
      },
      {
        type: Keyword,
        id: :keyword_1,
        meta_key: :meta_key_1
      },
      {
        type: Keyword,
        id: :keyword_2,
        meta_key: :meta_key_1
      },
      {
        type: MediaEntry,
        id: :elefant,
        title: 'Elefant',
        created_at: 1,
        last_change: 1
      },
      {
        type: MediaEntry,
        id: :zebra,
        title: 'Zebra',
        created_at: 2,
        last_change: 2
      },
      {
        type: MediaEntry,
        id: :rhino,
        title: 'Rhino',
        created_at: 3,
        last_change: 3
      },
      {
        type: Collection,
        id: :zoo_of_animals,
        title: 'Zoo of Animals',
        created_at: 1,
        last_change: 1,
        children: [:elefant, :zebra, :rhino]
      },
      {
        type: Collection,
        id: :zoo_of_zoos,
        title: 'Zoo of Zoos',
        created_at: 2,
        last_change: 2,
        children: [:zoo_of_animals]
      },
      {
        type: Collection,
        id: :zoo_of_all,
        title: 'Zoo of All',
        created_at: 3,
        last_change: 3,
        children: [:zoo_of_animals, :elefant]
      },
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
