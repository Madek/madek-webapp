require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './shared/batch_selection_helper'
include BatchSelectionHelper

feature 'transfer responsibility' do

  scenario 'check link visible if responsible' do
    user = create_user
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    check_responsible_and_link(user, true)
  end

  scenario  'check link not visible if not responsible' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user2)
    open_permissions(media_entry)
    check_responsible_and_link(user1, false)
  end

  scenario 'check media entry checkbox behaviour' do
    user = create_user
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    click_link
    check_checkboxes(MediaEntry, true, true, true, true)
    click_checkbox(:download)
    check_checkboxes(MediaEntry, true, false, false, false)
    click_checkbox(:manage)
    check_checkboxes(MediaEntry, true, true, true, true)
    click_checkbox(:edit)
    check_checkboxes(MediaEntry, true, true, false, false)
    click_checkbox(:edit)
    check_checkboxes(MediaEntry, true, true, true, false)
    click_checkbox(:view)
    check_checkboxes(MediaEntry, false, false, false, false)
    click_checkbox(:view)
    check_checkboxes(MediaEntry, true, false, false, false)
  end

  scenario 'check collection checkbox behaviour' do
    user = create_user
    collection = create_collection(user)
    login_user(user)
    open_permissions(collection)
    click_link
    check_checkboxes(Collection, true, nil, true, true)
    click_checkbox(:manage)
    check_checkboxes(Collection, true, nil, true, false)
    click_checkbox(:edit)
    check_checkboxes(Collection, true, nil, false, false)
    click_checkbox(:edit)
    check_checkboxes(Collection, true, nil, true, false)
    click_checkbox(:view)
    check_checkboxes(Collection, false, nil, false, false)
    click_checkbox(:view)
    check_checkboxes(Collection, true, nil, false, false)
  end

  scenario 'check clear user' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    click_link
    check_submit(false)
    choose_user(user2)
    check_submit(true)
    click_clear_user
    check_submit(false)
  end

  scenario 'check selecting responsible user' do
    user = create_user
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    click_link
    check_submit(false)
    choose_user(user)
    check_submit(false)
  end

  scenario 'successful transfer responsibility for media entry' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_link
    choose_user(user2)
    click_checkbox(:edit)
    click_submit_button
    wait_until_form_disappeared
    check_responsible_and_link(user2, false)
    check_permissions(user1, media_entry, MediaEntry, true, true, false, false)
  end

  scenario 'successful transfer responsibility for collection' do
    user1 = create_user
    user2 = create_user
    collection = create_collection(user1)
    login_user(user1)
    open_permissions(collection)
    check_responsible_and_link(user1, true)
    click_link
    choose_user(user2)
    click_checkbox(:manage)
    click_submit_button
    wait_until_form_disappeared
    check_responsible_and_link(user2, false)
    check_permissions(user1, collection, Collection, true, nil, true, false)
  end

  scenario 'transfer responsibility for not responsible media entry' do
    user1 = create_user
    user2 = create_user
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_link

    media_entry.responsible_user = user2
    media_entry.save!
    media_entry.reload
    choose_user(user2)
    click_submit_button

    check_error_message(:ajax_form_no_longer_authorized)
    click_cancel_button
    check_responsible_and_link(user1, true)
  end

  scenario 'batch transfer responsibility for media entries' do
    user1 = create_user
    user2 = create_user
    media_entry1 = create_media_entry(user1, 'Media Entry 1')
    media_entry2 = create_media_entry(user2, 'Media Entry 2')
    media_entry3 = create_media_entry(user1, 'Media Entry 3')
    parent = create_collection(user1)

    all_media_entries = [media_entry1, media_entry2, media_entry3]
    add_all_to_parent(all_media_entries, parent)

    login_user(user1)
    open_resource(parent)
    toggle_select_all
    open_dropdown
    check_given_counts(
      media_entries_transfer_responsibility: 2
    )
    click_batch_action(:media_entries_transfer_responsibility)

    choose_user(user2)
    click_submit_button
    wait_until_form_disappeared

    open_resource(parent)
    toggle_select_all
    open_dropdown
    check_given_counts(
      media_entries_transfer_responsibility: 0
    )
  end

  scenario 'batch transfer responsibility for collections' do
    user1 = create_user
    user2 = create_user
    collection1 = create_collection(user1, 'Collection 1')
    collection2 = create_collection(user2, 'Collection 2')
    collection3 = create_collection(user1, 'Collection 3')
    parent = create_collection(user1)

    all_collections = [collection1, collection2, collection3]
    add_all_to_parent(all_collections, parent)

    login_user(user1)
    open_resource(parent)
    toggle_select_all
    open_dropdown
    check_given_counts(
      collections_transfer_responsibility: 2
    )
    click_batch_action(:collections_transfer_responsibility)

    choose_user(user2)
    click_submit_button
    wait_until_form_disappeared

    open_resource(parent)
    toggle_select_all
    open_dropdown
    check_given_counts(
      collections_transfer_responsibility: 0
    )
  end

  scenario 'check batch selection' do
    user1 = create_user
    user2 = create_user
    media_entry1 = create_media_entry(user1, 'Media Entry 1')
    media_entry2 = create_media_entry(user2, 'Media Entry 2')
    media_entry3 = create_media_entry(user1, 'Media Entry 3')
    media_entry4 = create_media_entry(user2, 'Media Entry 4')
    collection1 = create_collection(user1, 'Collection 1')
    collection2 = create_collection(user2, 'Collection 2')
    collection3 = create_collection(user2, 'Collection 3')
    parent = create_collection(user1)

    all_media_entries = [media_entry1, media_entry2, media_entry3, media_entry4]
    all_collections = [collection1, collection2, collection3]
    all_resources = all_media_entries.concat all_collections

    unpublish(media_entry3)
    give_all_permissions(media_entry4, user1)
    add_all_to_parent(all_resources, parent)

    login_user(user1)
    open_resource(parent)

    open_dropdown
    check_all_items_inactive
    toggle_select_all

    open_dropdown
    check_all_counts(
      add_to_set: 6,
      remove_from_set: 6,
      media_entries_metadata: 2,
      collections_metadata: 1,
      media_entries_permissions: 2,
      collections_permissions: 1,
      media_entries_transfer_responsibility: 1,
      collections_transfer_responsibility: 1
    )
    check_all_highlights(
      add_to_set: all_media_entries,
      remove_from_set: all_media_entries,
      media_entries_metadata: [media_entry1, media_entry4],
      collections_metadata: [collection1],
      media_entries_permissions: [media_entry1, media_entry4],
      collections_permissions: [collection1],
      media_entries_transfer_responsibility: [media_entry1],
      collections_transfer_responsibility: [collection1]
    )
  end

  private

  def click_clear_user
    find('form[name="transfer_responsibility"]').find(
      'a.icon-close').click
  end

  def check_submit(active)
    button = find('form[name="transfer_responsibility"]').find(
      'button', text: I18n.t(:transfer_responsibility_submit))
    expect(button[:disabled]).to eq(active ? nil : 'true')
  end

  def add_all_to_parent(resources, parent)
    resources.each do |resource|
      resource.parent_collections << parent
    end
  end

  def unpublish(media_entry)
    media_entry.is_published = false
    media_entry.save!
    media_entry.reload
  end

  def give_all_permissions(resource, user)
    permissions = {
      user: user,
      get_metadata_and_previews: true,
      get_full_size: true,
      edit_metadata: true,
      edit_permissions: true
    }
    resource.user_permissions.create!(permissions)
    resource.save!
    resource.reload
  end

  def open_resource(resource)
    visit(send("#{resource.class.name.underscore}_path", resource))
  end

  def user_to_string(user)
    person = user.person
    "#{person.first_name} #{person.last_name} (#{person.pseudonym})"
  end

  def check_error_message(message_key)
    find('form[name="transfer_responsibility"]').find(
      '.ui-alerts', text: I18n.t(message_key))
  end

  def check_permissions(user, resource, type, view, download, edit, manage)
    permissions = resource.user_permissions.where(user: user).first
    if type == MediaEntry
      expect(permissions[:get_metadata_and_previews]).to eq(view)
      expect(permissions[:get_full_size]).to eq(download)
      expect(permissions[:edit_metadata]).to eq(edit)
      expect(permissions[:edit_permissions]).to eq(manage)
    elsif type == Collection
      expect(permissions[:get_metadata_and_previews]).to eq(view)
      expect(download).to eq(nil)
      expect(permissions[:edit_metadata_and_relations]).to eq(edit)
      expect(permissions[:edit_permissions]).to eq(manage)
    else
      raise 'Type not supported: ' + type
    end
  end

  def wait_until_form_disappeared
    wait_until do
      all('form[name="transfer_responsibility"]').empty?
    end
  end

  def click_submit_button
    find('form[name="transfer_responsibility"]').find(
      'button', text: I18n.t(:transfer_responsibility_submit)).click
  end

  def click_cancel_button
    find('form[name="transfer_responsibility"]').find(
      'a', text: I18n.t(:transfer_responsibility_cancel)).click
  end

  def choose_user(user)
    form = find('form[name="transfer_responsibility"]')
    autocomplete_and_choose_first(form, user.login)
  end

  def check_checkbox(type, id, active)
    within('form[name="transfer_responsibility"]') do
      if id == :download && type != MediaEntry
        expect(active).to eq(nil)
        expect(page).to have_no_selector(
          "input[name=\"transfer_responsibility[permissions][#{id}]\"]")
      else
        element = find(
          "input[name=\"transfer_responsibility[permissions][#{id}]\"]")
        expected = active ? 'true' : nil
        expect(element[:checked]).to eq(expected)
      end
    end
  end

  def click_checkbox(id)
    within('form[name="transfer_responsibility"]') do
      find("input[name=\"transfer_responsibility[permissions][#{id}]\"]").click
    end
  end

  def check_checkboxes(type, view, download, edit, manage)
    check_checkbox(type, :view, view)
    check_checkbox(type, :download, download)
    check_checkbox(type, :edit, edit)
    check_checkbox(type, :manage, manage)
  end

  def open_permissions(resource)
    visit send("permissions_#{resource.class.name.underscore}_path", resource)
  end

  def click_link
    find('.tab-content')
      .find('a', text: I18n.t(:permissions_transfer_responsibility_link))
      .click
  end

  def check_responsible_and_link(user, visible)
    within '.tab-content' do

      find('form[name="ui-rights-management"]').find(
        '.ui-info-box', text: user_to_string(user))

      expect(page).to have_selector(
        'a',
        text: I18n.t(:permissions_transfer_responsibility_link),
        count: (visible ? 1 : 0))
    end
  end

  def create_user
    FactoryGirl.create(:user)
  end

  def create_collection(user, title = nil)
    collection = FactoryGirl.create(
      :collection,
      get_metadata_and_previews: true,
      responsible_user: user,
      creator: user)
    if title
      MetaDatum::Text.create!(
        collection: collection,
        string: title,
        meta_key: meta_key_title,
        created_by: user)
    end
    collection
  end

  def create_media_entry(user, title = nil)
    media_entry = FactoryGirl.create(
      :media_entry,
      get_metadata_and_previews: true,
      responsible_user: user,
      creator: user)
    FactoryGirl.create(
      :media_file_for_image,
      media_entry: media_entry)
    if title
      MetaDatum::Text.create!(
        media_entry: media_entry,
        string: title,
        meta_key: meta_key_title,
        created_by: user)
    end
    media_entry
  end

  def login_user(user)
    sign_in_as(user.login, user.password)
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end
end
