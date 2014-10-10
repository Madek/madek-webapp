require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'import', 'shared.rb')

feature "Delete" do
  include Features::Import::Shared

  background do
    @current_user = sign_in_as "normin"
  end

  scenario "Access delete action for media resources on my dashboard" do

    visit "/"

    assert_visible_delete_action_for_media_resources_where_user_responsible
    assert_not_visible_delete_action_for_media_resources_where_user_not_responsible

  end

  scenario "Access delete action for media resources on a media resources list", browser: :headless do

    visit media_resources_path
    expect(page).to have_selector(".ui-resource")

    assert_visible_delete_action_for_media_resources_where_user_responsible
    assert_not_visible_delete_action_for_media_resources_where_user_not_responsible

  end

  scenario "Access delete action for media entry on media entry page" do

    open_media_entry_for_user_with_all_permissions_but_not_responsible
    assert_not_visible_delete_action_for_current_resource
    open_media_entry_current_user_responsible
    assert_visible_delete_action_for_current_resource

  end

  scenario "Access delete action for media set on media set page", browser: :firefox do

    # create missing test data
    resource = FactoryGirl.create :media_set
    FactoryGirl.create :userpermission, user: @current_user, media_resource: resource,
      view: true,
      download: true,
      edit: true,
      manage: true

    open_media_set_for_user_with_all_permissions_but_not_responsible
    assert_not_visible_delete_action_for_current_resource
    open_media_set_current_user_responsible
    assert_visible_delete_action_for_current_resource

  end

  scenario "Importing and deleting an image", browser: :firefox do

    remember_resources

    click_on_text "Medien importieren"
    assert_exact_url_path "/import"

    attach_test_file 'images/berlin_wall_01.jpg'

    start_uploading
    click_on_text "Berechtigungen speichern"

    # After the next page is loaded
    # I set the input in the fieldset with "title" as meta-key to "Berlin Wall"
    fill_meta_key_field_with 'Berlin Wall', 'title'
    # I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL"
    fill_meta_key_field_with 'WTFPL', 'copyright notice'

    click_on_text "Weiter..."

    # After the next page is loaded
    click_on_text "Import abschliessen"

    # I remember the last imported media_entry with media_file and the actual file
    @media_entry = MediaEntry.reorder(created_at: :desc,id: :asc).first
    @media_file = @media_entry.media_file
    @file = @media_file.file_storage_location

    visit media_resource_path(@media_entry)

    # The media_resource does exist
    expect(MediaEntry.where(id: @media_entry.id).count).to be > 0
    # The media_file does exist
    expect(MediaFile.where(id: @media_file.id).count).to be > 0 
    # The actual_file does exist
    expect(File.exists? @file).to be true

    find('[data-delete-action]').click
    click_on_text 'Löschen'
    wait_for_ajax

    # The media_entry doesn't exist anymore
    expect(MediaEntry.where(id: @media_entry.id).count).to be == 0
    # The media_file doesn't exist anymore
    expect(MediaFile.where(id: @media_file.id).count).to be == 0
    # The actual_file doesn't exist anymore
    expect(File.exists? @file).to be false

  end

  def assert_not_visible_delete_action_for_current_resource
    expect(page).not_to have_selector ".ui-body-title-actions [data-delete-action]"
  end

  def assert_visible_delete_action_for_current_resource
    expect(page).to have_selector ".ui-body-title-actions [data-delete-action]"
  end

  def assert_visible_delete_action_for_media_resources_where_user_responsible
    all(".ui-resource[data-id]").each do |resource_el|
      media_resource = MediaResource.find resource_el["data-id"]
      if @current_user.authorized?(:delete, media_resource)
        expect(resource_el).to have_selector("[data-delete-action]", visible: false)
      end
    end
  end

  def assert_not_visible_delete_action_for_media_resources_where_user_not_responsible
    all(".ui-resource[data-id]").each do |resource_el|
      media_resource = MediaResource.find resource_el["data-id"]
      if not @current_user.authorized?(:delete, media_resource)
        expect(resource_el).not_to have_selector("[data-delete-action]")
      end
    end
  end

  def open_media_entry_current_user_responsible
    visit media_resource_path @current_user.media_entries.first
  end

  def open_media_set_current_user_responsible
    visit media_resource_path @current_user.media_sets.first
  end

  def open_media_entry_for_user_with_all_permissions_but_not_responsible
    media_entry = MediaEntry.where.not(user_id: @current_user.id).detect { |resource| fully_authorized? @current_user, resource }
    visit media_resource_path media_entry
  end

  def open_media_set_for_user_with_all_permissions_but_not_responsible
    media_set = MediaSet.where.not(user_id: @current_user.id).detect { |resource| fully_authorized? @current_user, resource }
    visit media_resource_path(media_set)
  end

  def fully_authorized?(user, resource)
    user.authorized?(:view, resource) and
      user.authorized?(:edit, resource) and
      user.authorized?(:download, resource) and
      user.authorized?(:manage, resource)
  end

end
