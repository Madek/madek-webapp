require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Setting and displaying configurable contexts in list views" do

  scenario "Setting and displaying configurable contexts in list views", browser: :firefox do

    @current_user = sign_in_as "adam"

    @media_set = MediaSet.find "b23c6f19-4fdd-4e7d-b48e-697953fe5f12"

    visit media_set_path(@media_set)

    find("#list-view").click

    # There is not an element with the data-context-id "Institution" in the ui-resource-body
    expect(page).not_to have_selector(".ui-resource-body *[data-context-id='Institution']")
    # There is not an element with the data-context-id "Landschaftsvisualisierung" in the ui-resource-body
    expect(page).not_to have_selector(".ui-resource-body *[data-context-id='Landschaftsvisualisierung']")

    visit "/app_admin/settings/second_displayed_context_id/edit"

    fill_in "app_settings[second_displayed_context_id]", with: "Institution"

    submit_form

    visit "/app_admin/settings/third_displayed_context_id/edit"

    fill_in "app_settings[third_displayed_context_id]", with: "Landschaftsvisualisierung"

    submit_form

    assert_success_message

    visit media_set_path(@media_set)

    find("#list-view").click

    scroll_to_bottom
    # There is an element with the data-context-id "Institution" in the ui-resource-body
    expect(page).to have_selector(".ui-resource-body *[data-context-id='Institution']")
    # There is an element with the data-context-id "Landschaftsvisualisierung" in the ui-resource-body
    expect(page).to have_selector(".ui-resource-body *[data-context-id='Landschaftsvisualisierung']", visible: false)
  end
end
