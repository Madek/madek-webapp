require 'rails_helper'
require 'spec_helper_feature_shared'

require Rails.root.join "spec","features","shared.rb"
include Features::Shared

feature "Setting and using custom URLs for MediaResources" do

  scenario "Creating a URL" do

    @current_user = sign_in_as "normin"
    visit_user_first_media_entry

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"

    expect(page).to have_content "Adressen für"

    click_on_text "Adresse anlegen / übertragen"

    fill_in "url", with: "the_new_url_for_testing"

    submit_form

    assert_success_message

    expect(page).to have_content "the_new_url_for_testing"

    click_on_text "the_new_url_for_testing"
    assert_partial_url_path "entries"

  end

  scenario "Defining and redirection to the primary url", browser: :headless do

    @current_user = sign_in_as "normin"
    visit_user_first_media_entry
    @path = current_path

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"

    click_on_text "Adresse anlegen / übertragen"

    fill_in "url", with: "the_new_url_for_testing"
    submit_form

    click_on_text "the_new_url_for_testing"
    assert_partial_url_path "entries"
    expect(current_path).to eq @path

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    find("#the_new_url_for_testing", text: "Weiterleitung")

    find("#the_new_url_for_testing button", text: "Als primäre Adresse setzen").click
    assert_success_message

    find("#the_new_url_for_testing", text: "Primäre Adresse")
    click_on_text "the_new_url_for_testing"
    assert_partial_url_path "entries"
    expect(current_path).to match "the_new_url_for_testing"

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    find("#_uuid a", match: :first).click
    expect(current_path).to match "the_new_url_for_testing"

  end

  scenario "Transfering URL and redirection from '/media_resources/...'", browser: :headless do

    @current_user = sign_in_as "normin"
    visit_user_first_media_entry
    @path = current_path

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    click_on_text "Adresse anlegen / übertragen"

    fill_in "url", with: "the_new_url_for_testing"
    submit_form

    expect(find("#the_new_url_for_testing")).to have_content "Weiterleitung"

    find("#the_new_url_for_testing button", text: "Als primäre Adresse setzen").click
    assert_success_message

    expect(find("#the_new_url_for_testing")).to have_content "Primäre Adresse"

    click_on_text "the_new_url_for_testing"

    visit "/media_resources/the_new_url_for_testing"
    expect(current_path).to match "entries/the_new_url_for_testing"

    visit_user_first_media_set

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    click_on_text "Adresse anlegen / übertragen"

    fill_in "url", with: "the_new_url_for_testing"
    submit_form

    expect(page).to have_content "Übertragung der Adresse bestätigen"

    click_on_text "Adresse übertragen"
    assert_success_message

    find("#the_new_url_for_testing button", text: "Als primäre Adresse setzen").click
    assert_success_message

    visit "/media_resources/the_new_url_for_testing"
    expect(current_path).to match "sets/the_new_url_for_testing"

  end

  scenario "Creating URLs too quickly for one media_resource is not allowed", browser: :headless do

    @current_user = sign_in_as "normin"
    visit_user_first_media_entry

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    expect(page).to have_content "Adressen für"
    click_on_text "Adresse anlegen / übertragen"

    fill_in "url", with: "the_new_url_for_testing"
    submit_form
    assert_success_message
    expect(page).to have_content "the_new_url_for_testing"

    click_on_text "Adresse anlegen / übertragen"
    fill_in "url", with: "a_second_url_for_testing"
    submit_form
    assert_error_alert
    expect(find("#url").value).to eq "a_second_url_for_testing"

  end

  scenario "Creating URLs quickly as a Ueberadmin" do

    @current_user = sign_in_as "adam"

    # I remember a media_entry that doesn't belong to me, has no public, nor other permissions
    @media_entry = @media_resource = @resource = MediaEntry.where.not(user_id: @current_user.id).first
    @media_entry.update_attributes! view: false, download: false, manage: false, edit: false
    @media_entry.userpermissions.destroy_all
    @media_entry.grouppermissions.destroy_all
    ##########################################

    click_on_text "Adam Admin"
    click_on_text "In Admin-Modus wechseln"

    visit media_resource_path(@media_entry)

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    expect(page).to have_content "Adressen für"
    click_on_text "Adresse anlegen / übertragen"

    fill_in "url", with: "the_new_url_for_testing"
    submit_form
    assert_success_message
    expect(page).to have_content "the_new_url_for_testing"

    click_on_text "the_new_url_for_testing"
    assert_partial_url_path "entries"

    click_on_text "Weitere Aktionen"
    click_on_text "Adressen"
    click_on_text "Adresse anlegen / übertragen"
    fill_in "url", with: "a_second_url_for_testing"
    submit_form
    assert_success_message
    expect(page).to have_content "a_second_url_for_testing"

  end

end
