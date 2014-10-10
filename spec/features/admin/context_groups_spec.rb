require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Context Groups", browser: :firefox do
  scenario "Removing a meta context" do
    sign_in_as "adam"
    visit "/app_admin/context_groups"
    first("a", text: "Edit").click
    all("#sortable li", count: 4)
    first("input[type='checkbox']").set(true)
    click_button "Submit"
    assert_success_message

    first("a", text: "Edit").click
    all("#sortable li", count: 3)
  end
end
