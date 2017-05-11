require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/batch_selection_helper'
include BatchSelectionHelper

feature 'clipboard' do

  scenario 'show "empty message" on clipboard if it does not exist' do
    user = create_user
    login(user)
    visit_dashboard
    click_menu_entry
    expect(page).to have_content(I18n.t(:clipboard_empty_message))
  end

  scenario 'add single media entry and show clipboard' do
    user = create_user
    media_entry = create_media_entry('Media Entry 1', user)
    scenario_add_single_resource_and_show_clipboard(user, media_entry)
  end

  scenario 'add single collection and show clipboard' do
    user = create_user
    collection = create_collection('Collection 1', user)
    scenario_add_single_resource_and_show_clipboard(user, collection)
  end

  scenario 'add all to clipboard' do
    data = prepare_data

    login(data[:user])

    visit_resource(data[:parent])
    check_resources_in_box(
      data[:all_resources]
    )
    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 4, all: true },
      add_to_set: { count: 0, active: false },
      remove_from_set: { count: 0, active: false },
      media_entries_metadata: { count: 0, active: false },
      resources_destroy: { count: 0, active: false },
      collections_metadata: { count: 0, active: false },
      media_entries_permissions: { count: 0, active: false },
      collections_permissions: { count: 0, active: false },
      media_entries_transfer_responsibility: { count: 0, active: false },
      collections_transfer_responsibility: { count: 0, active: false }
    )
    click_batch_action(:add_to_clipboard, all: true, all_count: 4)
    click_dialog_ok
    check_add_success_message

    open_clipboard
    check_resources_in_box(data[:all_resources])
  end

  scenario 'add selected to clipboard' do
    data = prepare_data

    login(data[:user])

    visit_resource(data[:parent])
    check_resources_in_box(
      data[:all_resources]
    )
    select_mixed([data[:media_entry_2], data[:collection_1]])
    click_dropdown
    check_full_dropdown(
      add_to_clipboard: { count: 2, all: false },
      add_to_set: { count: 2 },
      remove_from_set: { count: 2 },
      media_entries_metadata: { count: 1 },
      collections_metadata: { count: 1 },
      resources_destroy: { count: 2 },
      media_entries_permissions: { count: 1 },
      collections_permissions: { count: 1 },
      media_entries_transfer_responsibility: { count: 1 },
      collections_transfer_responsibility: { count: 1 }
    )
    click_batch_action(:add_to_clipboard, all: false)
    check_add_success_message

    open_clipboard
    check_resources_in_box(
      [data[:media_entry_2], data[:collection_1]])
  end

  private

  # rubocop:disable Metrics/MethodLength
  def prepare_data
    user = create_user
    media_entry_1 = create_media_entry('Media Entry 1', user)
    media_entry_2 = create_media_entry('Media Entry 2', user)
    collection_1 = create_collection('Collection 1', user)
    collection_2 = create_collection('Collection 2', user)

    all_media_entries = [media_entry_1, media_entry_2]
    all_collections = [collection_1, collection_2]
    all_resources = all_media_entries.concat(all_collections)

    parent = create_collection('Parent', user)
    add_all_to_parent(all_resources, parent)

    {
      user: user,
      media_entry_1: media_entry_1,
      media_entry_2: media_entry_2,
      collection_1: collection_1,
      collection_2: collection_2,
      all_media_entries: all_media_entries,
      all_collections: all_collections,
      all_resources: all_resources,
      parent: parent
    }
  end
  # rubocop:enable Metrics/MethodLength

  def open_clipboard
    visit my_dashboard_section_path(:clipboard)
  end

  def open_drafts
    visit my_dashboard_section_path(:unpublished_entries)
  end

  def check_add_success_message
    find('#app-alerts').find(
      '.ui-alert', text: I18n.t(:clipboard_batch_add_success))
  end

  def click_dialog_ok
    find('.modal').find('button', text: I18n.t(:clipboard_ask_add_all_ok)).click
  end

  def add_all_to_parent(resources, parent)
    resources.each do |resource|
      resource.parent_collections << parent
    end
  end

  def unpublish_media_entry(media_entry)
    media_entry.is_published = false
    media_entry.save!
    media_entry.reload
  end

  def scenario_add_single_resource_and_show_clipboard(user, resource)
    login(user)
    visit_resource(resource)
    open_set_manager_and_add_to_clipboard
    visit_dashboard
    click_menu_entry
    check_on_clipboard
    check_resources_in_box([resource])
  end

  def check_resources_in_box(expected_resources)
    ui_resources = find('.ui-polybox').find('.ui-resources-page-items')
      .all('.ui-resource')

    actual_titles = ui_resources.map do |ui_resource|
      ui_resource.find('.ui-thumbnail-meta-title').text
    end

    expected_titles = expected_resources.map &:title

    expect(actual_titles.sort).to eq(expected_titles.sort)
  end

  def check_on_clipboard
    wait_until { current_path == my_dashboard_section_path(:clipboard) }
  end

  def click_menu_entry
    find('.ui-side-navigation').find(
      '.ui-side-navigation-item',
      text: I18n.t('sitemap_clipboard')
    ).find('a').click
  end

  def open_set_manager_and_add_to_clipboard
    button = find('.ui-body-title-actions').find(
      'button[title="' + I18n.t(:resource_action_manage_collections) + '"]')
    button.click

    find('h3', text: I18n.t(:resource_select_collection_title))
    find('.ui-modal-footer').find('input[type=checkbox]').click
    find('.ui-modal-footer').find('button').click
  end

  def visit_resource(resource)
    visit self.send("#{resource.class.name.underscore}_path", resource)
  end

  def visit_media_entry(media_entry)
    visit media_entry_path(media_entry)
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
