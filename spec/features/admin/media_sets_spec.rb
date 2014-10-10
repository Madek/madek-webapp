require "rails_helper"
require "spec_helper_feature_shared"

feature "Admin Media Sets" do
  background { sign_in_as "adam" }

  scenario "Showing media sets" do
    visit "/app_admin"

    dropdown = find("a.dropdown-toggle", text: "Media Resources").
               find(:xpath, '..').
               find('ul.dropdown-menu')

    within dropdown do
      expect(page).to have_link("Media Sets")
      click_link "Media Sets"
    end
    expect(current_path).to eq "/app_admin/media_sets"
  end

  scenario "Showing details of a media set" do
    visit "/app_admin/media_sets"
    first("a", text: "Details").click

    expect(current_path).to match(/^\/app_admin\/media_sets\/.+$/)
  end

  scenario "Delete a set with all children" do
    expect{ MediaResource.find_by! previous_id: 6 }.not_to raise_error

    visit "/app_admin/media_sets/38"

    click_link "Delete with all children"
    expect{ MediaResource.find_by! previous_id: 38 }.to raise_error(ActiveRecord::RecordNotFound)
    expect{ MediaResource.find_by! previous_id: 6 }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario "Delete a set without all children" do
    expect{ MediaResource.find_by! previous_id: 6 }.not_to raise_error

    visit "/app_admin/media_sets/38"

    click_link "Delete without children"
    expect{ MediaResource.find_by! previous_id: 38 }.to raise_error(ActiveRecord::RecordNotFound)
    expect{ MediaResource.find_by! previous_id: 6 }.not_to raise_error
  end

  scenario "Managing individual context" do
    context_name = "Zett"

    visit "/app_admin/media_sets/2"
    click_link "Manage individual contexts"

    expect(page).to have_css("table.individual_contexts tr.individual_context[data-name='#{context_name}']")
    within "table.individual_contexts tr.individual_context[data-name='#{context_name}']" do
      click_link "Remove"
    end
    expect(page).not_to have_css("table.individual_contexts tr.individual_context[data-name='#{context_name}']")

    within "table.contexts tr.context[data-id='#{context_name}']" do
      click_link "Add"
    end
    expect(page).to have_css("table.individual_contexts tr.individual_context[data-name='#{context_name}']")

    visit "/app_admin/media_sets/3"
    click_link "Manage individual contexts"
    expect(page).to have_css("table.individual_contexts tr.individual_context[data-name='#{context_name}']")
  end
end
