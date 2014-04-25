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

  scenario "Updating the title", browser: :headless do

    sign_in_as 'normin'

    @media_entry_with_title = FactoryGirl.create :media_entry_with_image_media_file, user: @me
    meta_key = MetaKey.find_by_id(:title) 
    @media_entry_with_title.meta_data.create meta_key: meta_key, value: "AN EXISTING TITLE"
    @media_entry_without_title = FactoryGirl.create :media_entry_with_image_media_file, user: @me

    add_to_the_clipboard @media_entry_with_title
    add_to_the_clipboard @media_entry_without_title

    visit my_dashboard_path
    i_click_on 'Zwischenablage'
    i_click_on 'Aktionen'

    # wait for the clipboard to be fully open
    find(".ui-clipboard.ui-open")

    # both entries must be visible in the clip board
    find(".ui-clipboard .ui-resource[data-id='#{@media_entry_with_title.id}']",visible: true)
    find(".ui-clipboard .ui-resource[data-id='#{@media_entry_without_title.id}']",visible: true)

    i_click_on "Metadaten von Medieneinträgen editieren"

    # unfortunately, there is no attribute that points to the meta_key 'title'
    # so we use the generic rails name
    find("textarea[name='resource[meta_data_attributes][1][value]']").set("THE NEW TITLE")

    i_click_on "Speichern"

    # the new title is now displayed
    expect(page).to have_content "THE NEW TITLE"

    # the old title has not been overwritten
    expect(page).to have_content "AN EXISTING TITLE"


  end
end
