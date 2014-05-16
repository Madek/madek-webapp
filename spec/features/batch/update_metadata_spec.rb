require "spec_helper"
require "spec_helper_feature"
require 'spec_helper_feature_shared'

feature "Batch edit metadata" do

  def add_to_the_clipboard media_resource
    visit media_resource_path(media_resource)
    find("a[data-clipboard-toggle]").click
    wait_until{page.evaluate_script(%<$.active>) == 0}
    wait_until{find(".ui-clipboard li.ui-resource[data-id='#{media_resource.id}']",visible: false)}
  end

  def create_media_entries
    @media_entry1 = FactoryGirl.create :media_entry_with_image_media_file, user: @current_user
    @media_entry2 = FactoryGirl.create :media_entry_with_image_media_file, user: @current_user
  end

  def place_entries_in_clipboard_and_open_batch_edit
    add_to_the_clipboard @media_entry1
    add_to_the_clipboard @media_entry2

    visit my_dashboard_path
    click_on_text 'Zwischenablage'
    click_on_text 'Aktionen'

    # wait for the clipboard to be fully open
    find(".ui-clipboard.ui-open")

    # both entries must be visible in the clip board
    find(".ui-clipboard .ui-resource[data-id='#{@media_entry1.id}']",visible: true)
    find(".ui-clipboard .ui-resource[data-id='#{@media_entry2.id}']",visible: true)

    click_on_text "Metadaten von Medieneinträgen editieren"
  end

  def find_input_for_meta_key name
    find("fieldset[data-meta-key='#{name}']").find("textarea,input")
  end

  scenario "Updating an unset title meta-datum", browser: :headless do
    @current_user= sign_in_as 'normin'

    create_media_entries
    place_entries_in_clipboard_and_open_batch_edit

    find_input_for_meta_key("title").set("THE NEW TITLE")

    click_on_text "Speichern"

    visit media_entry_path(@media_entry1)
    expect(page).to have_content "THE NEW TITLE"

    visit media_entry_path(@media_entry2)
    expect(page).to have_content "THE NEW TITLE"
  end

  scenario "Updating a mixed title meta-datum", browser: :headless do
    @current_user= sign_in_as 'normin'

    create_media_entries
    @media_entry1.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: "AN EXISTING TITLE"

    place_entries_in_clipboard_and_open_batch_edit

    find_input_for_meta_key("title").set("THE NEW TITLE")

    click_on_text "Speichern"

    visit media_entry_path(@media_entry1)
    expect(page).to have_content "THE NEW TITLE"

    visit media_entry_path(@media_entry2)
    expect(page).to have_content "THE NEW TITLE"
  end


  scenario "Deleting a non mixed title meta-datum", browser: :jsbrowser do
    @current_user= sign_in_as 'normin'

    create_media_entries
    @media_entry1.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: "AN EXISTING TITLE"
    @media_entry2.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: "AN EXISTING TITLE"

    place_entries_in_clipboard_and_open_batch_edit

    find_input_for_meta_key("title").set("")

    click_on_text "Speichern"

    visit media_entry_path(@media_entry1)
    expect(page).not_to have_content "AN EXISTING TITLE"

    visit media_entry_path(@media_entry2)
    expect(page).not_to have_content "AN EXISTING TITLE"
  end

end
