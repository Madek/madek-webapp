require "spec_helper"
require "spec_helper_feature"

feature "Batch edit metadata" do

  def sign_in_as login, password= 'password'
    visit "/"
    find("a#database-user-login-tab").click
    find("input[name='login']").set(login)
    find("input[name='password']").set(password)
    find("button[type='submit']").click
    @me = @current_user = User.find_by_login login
  end

  def add_to_the_clipboard media_resource
    visit media_resource_path(media_resource)
    find("a[data-clipboard-toggle]").click
    wait_until{page.evaluate_script(%<$.active>) == 0}
    wait_until{find(".ui-clipboard li.ui-resource[data-id='#{media_resource.id}']",visible: false)}
  end

  def i_click_on text
    wait_until{ all("a, button", text: text, visible: true).size > 0}
    find("a, button",text: text).click
  end

  def create_media_entries
    @media_entry1 = FactoryGirl.create :media_entry_with_image_media_file, user: @me
    @media_entry2 = FactoryGirl.create :media_entry_with_image_media_file, user: @me
  end

  def place_entries_in_clipboard_and_open_batch_edit
    add_to_the_clipboard @media_entry1
    add_to_the_clipboard @media_entry2

    visit my_dashboard_path
    i_click_on 'Zwischenablage'
    i_click_on 'Aktionen'

    # wait for the clipboard to be fully open
    find(".ui-clipboard.ui-open")

    # both entries must be visible in the clip board
    find(".ui-clipboard .ui-resource[data-id='#{@media_entry1.id}']",visible: true)
    find(".ui-clipboard .ui-resource[data-id='#{@media_entry2.id}']",visible: true)

    i_click_on "Metadaten von Medieneinträgen editieren"
  end

  def find_input_for_meta_key name
    find("fieldset[data-meta-key='#{name}']").find("textarea,input")
  end

  scenario "Updating an unset title meta-datum", browser: :headless do
    sign_in_as 'normin'

    create_media_entries
    place_entries_in_clipboard_and_open_batch_edit

    find_input_for_meta_key("title").set("THE NEW TITLE")

    i_click_on "Speichern"

    visit media_entry_path(@media_entry1)
    expect(page).to have_content "THE NEW TITLE"

    visit media_entry_path(@media_entry2)
    expect(page).to have_content "THE NEW TITLE"
  end

  scenario "Updating a mixed title meta-datum", browser: :headless do
    sign_in_as 'normin'

    create_media_entries
    @media_entry1.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: "AN EXISTING TITLE"

    place_entries_in_clipboard_and_open_batch_edit

    find_input_for_meta_key("title").set("THE NEW TITLE")

    i_click_on "Speichern"

    visit media_entry_path(@media_entry1)
    expect(page).to have_content "THE NEW TITLE"

    visit media_entry_path(@media_entry2)
    expect(page).to have_content "THE NEW TITLE"
  end


  scenario "Deleting a non mixed title meta-datum", browser: :jsbrowser do
    sign_in_as 'normin'

    create_media_entries
    @media_entry1.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: "AN EXISTING TITLE"
    @media_entry2.meta_data \
      .create meta_key: MetaKey.find_by_id(:title), value: "AN EXISTING TITLE"

    place_entries_in_clipboard_and_open_batch_edit

    find_input_for_meta_key("title").set("")

    i_click_on "Speichern"

    visit media_entry_path(@media_entry1)
    expect(page).not_to have_content "AN EXISTING TITLE"

    visit media_entry_path(@media_entry2)
    expect(page).not_to have_content "AN EXISTING TITLE"
  end

end
