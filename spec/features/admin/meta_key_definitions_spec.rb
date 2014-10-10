require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Meta Key Definitions" do
  background do
    sign_in_as "adam"
    visit "/app_admin/contexts/core/edit"
  end

  scenario "Setting min & max length" do
    first("a", text: "Edit").click
    expect(find_field("meta_key_definition[length_min]")[:value]).to be_nil
    expect(find_field("meta_key_definition[length_max]")[:value]).to be_nil

    fill_in "meta_key_definition[length_min]", with: 10
    fill_in "meta_key_definition[length_max]", with: 64
    click_button "Save"
    expect(page).to have_css(".alert-success")

    first("a", text: "Edit").click
    expect(find_field("meta_key_definition[length_min]")[:value]).to eq("10")
    expect(find_field("meta_key_definition[length_max]")[:value]).to eq("64")
  end

  scenario "Setting input type" do
    first("a", text: "Edit").click
    expect(find("input[value='text_area']")[:checked]).to be_nil
    expect(find("input[value='text_field']")[:checked]).to be_nil

    find("input[value='text_area']").set(true)
    click_button "Save"
    expect(page).to have_css(".alert-success")

    first("a", text: "Edit").click
    expect(find("input[value='text_area']")[:checked]).to eq("checked")
    expect(find("input[value='text_field']")[:checked]).to be_nil
  end

  scenario "Changing position in scope of a context" do
    expect_order ["title", "author", "portrayed object dates", "keywords", "copyright notice", "owner"]

    within first("table tbody tr") do
      find(".move-down").click
    end
    expect(page).to have_css(".alert-success")
    expect_order ["author", "title", "portrayed object dates", "keywords", "copyright notice", "owner"]

    within all("table tbody tr").last do
      find(".move-up").click
    end
    expect(page).to have_css(".alert-success")
    expect_order ["author", "title", "portrayed object dates", "keywords", "owner", "copyright notice"]
  end

  def expect_order(order)
    expect(all("table tbody tr").collect { |row| row.first("td").text }).to eq(order)
  end
end
