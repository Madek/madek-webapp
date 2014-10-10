require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Permission Presets" do
  background do
    sign_in_as "adam"
    visit "/app_admin/permission_presets"
  end

  scenario "Creating new permission preset" do
    click_link "New permission preset"
    fill_in "permission_preset[name]", with: "NEW PRESET"
    check "permission_preset[edit]"
    check "permission_preset[view]"
    click_button "Create"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("NEW PRESET")
  end

  scenario "Editing a permission preset" do
    first("a", text: "Edit").click
    fill_in "permission_preset[name]", with: "EDITED PRESET"
    click_button "Update"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("EDITED PRESET")
  end

  scenario "Changing permission preset position" do
    second_row = all("table tbody tr")[1]
    third_row  = all("table tbody tr")[2]

    within second_row do
      find("a.down").click
    end
    expect(all("table tbody tr")[2][:id]).to eq(second_row[:id])
    expect(all("table tbody tr")[1][:id]).to eq(third_row[:id])
  end
end
