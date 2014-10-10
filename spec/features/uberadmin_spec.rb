require 'rails_helper'
require 'spec_helper_feature_shared'

require Rails.root.join "spec","support","ui_helpers.rb"
include UIHelpers

feature "Acting as an Uberadmin" do

  background do
    @current_user = sign_in_as "adam"
  end

  scenario "My resources", browser: :headless do

    visit "/media_resources?filterpanel=true"

    resources_counter = find("#resources_counter", match: :first).text.to_i

    click_on_text "Adam Admin"
    click_on_text "In Admin-Modus wechseln" 

    # I can see more resources than before
    expect(find("#resources_counter", match: :first).text.to_i).to be > resources_counter

    # I can see all resources
    expect(find("#resources_counter", match: :first).text.to_i).to eq MediaResource.count

    click_on_text "Adam Admin"
    click_on_text "Admin-Modus verlassen"

    # I see exactly the same number of resources as before
    expect(find("#resources_counter", match: :first).text.to_i).to be == resources_counter

  end

  scenario "Viewing and editing a private entry as Überadmin", browser: :firefox do

    media_entry = get_media_entry_from_other_user_without_permissions

    visit media_resource_path media_entry

    assert_exact_url_path "/my"
    expect(page).to have_content "Sie haben nicht die notwendige Zugriffsberechtigung."

    click_on_text "Adam Admin"
    click_on_text "In Admin-Modus wechseln" 

    visit media_resource_path media_entry

    click_link 'Metadaten editieren'

    assert_exact_url_path edit_media_resource_path media_entry

    fill_in "Titel des Werks", with: "XYZ Titel"
    submit_form

    assert_exact_url_path media_entry_path media_entry

    expect(page).to have_content "XYZ Titel"

    # I am the last editor of the remembered resource
    expect(MediaEntry.find(media_entry.id).editors.reorder(created_at: :desc, id: :asc).first).to be == @current_user

    click_on_text "Adam Admin"
    click_on_text "Admin-Modus verlassen"

    visit media_resource_path media_entry

    assert_exact_url_path "/my"
    expect(page).to have_content "Sie haben nicht die notwendige Zugriffsberechtigung."

  end

  scenario "Deleting a private media entry in admin mode", browser: :firefox do

    media_entry = get_media_entry_from_other_user_without_permissions

    visit media_resource_path media_entry

    assert_exact_url_path "/my"

    expect(page).to have_content "Sie haben nicht die notwendige Zugriffsberechtigung."

    click_on_text "Adam Admin"
    click_on_text "In Admin-Modus wechseln" 

    visit media_resource_path media_entry

    find("a[title='Löschen']").click
    # I confirm the modal
    find('.modal.in .primary-button').click
    wait_for_ajax
    # The media_entry doesn't exist anymore
    expect(MediaEntry.where(id: media_entry.id).count).to be 0

  end

  def get_media_entry_from_other_user_without_permissions
    media_entry = MediaEntry.where.not(user_id: @current_user.id).first
    media_entry.update_attributes! view: false, download: false, manage: false, edit: false
    media_entry.userpermissions.destroy_all
    media_entry.grouppermissions.destroy_all
    media_entry
  end

end
