require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Settings" do
  background do
    sign_in_as "adam"
    visit "/app_admin/settings"
  end

  scenario "Setting a featured set" do
    fill_in "app_settings[featured_set_id]", with: "434c473e-c685-4ea8-83f1-ceebff16c843"
    within "#special-sets-form" do
      click_button 'Change set', match: :first
    end

    expect(page).to have_css(".alert-success")
    expect(find_field("app_settings[featured_set_id]")[:value]).to eq("434c473e-c685-4ea8-83f1-ceebff16c843")
  end

  scenario "Setting a teaser set" do
    fill_in "app_settings[teaser_set_id]", with: "e499b452-ed3a-483a-9102-ff6fdb6fb6a5"
    within "#special-sets-form" do
      click_button 'Change set', match: :first
    end

    expect(page).to have_css(".alert-success")
    expect(find_field("app_settings[teaser_set_id]")[:value]).to eq("e499b452-ed3a-483a-9102-ff6fdb6fb6a5")
  end

  scenario "Setting a catalog set" do
    fill_in "app_settings[catalog_set_id]", with: "d2582be1-9180-46f1-93c6-4798de15f615"
    within "#special-sets-form" do
      click_button 'Change set', match: :first
    end

    expect(page).to have_css(".alert-success")
    expect(find_field("app_settings[catalog_set_id]")[:value]).to eq("d2582be1-9180-46f1-93c6-4798de15f615")
  end

  scenario "Setting a special set with empty value" do
    expect(find_field("app_settings[featured_set_id]")[:value]).to eq("d2582be1-9180-46f1-93c6-4798de15f615")

    fill_in "app_settings[featured_set_id]", with: ""
    within "#special-sets-form" do
      click_button 'Change set', match: :first
    end

    expect(page).to have_css(".alert-danger")
    expect(find_field("app_settings[featured_set_id]")[:value]).to eq("d2582be1-9180-46f1-93c6-4798de15f615")
  end

  scenario "Setting a special set with the same ID" do
    expect(find_field("app_settings[featured_set_id]")[:value]).to eq("d2582be1-9180-46f1-93c6-4798de15f615")
    within "#special-sets-form" do
      click_button 'Change set', match: :first
    end

    expect(page).to have_css(".alert-info", text: "The special sets have not been updated.")
    expect(find_field("app_settings[featured_set_id]")[:value]).to eq("d2582be1-9180-46f1-93c6-4798de15f615")
  end
end
