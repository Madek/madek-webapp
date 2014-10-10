require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Contexts" do
  background do
    sign_in_as "adam"
    visit "/app_admin/contexts"
  end

  scenario "Deleting a context" do
    first("a", text: "Delete").click

    expect(page).to have_css(".alert-success")
  end

  scenario "Editing a context's description" do

    expect(page).not_to have_content("DESCRIPTION")

    first("a", text: "Edit").click
    find("textarea[name='context[description]']").set("DESCRIPTION")
    find("input[type='submit']").click

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("DESCRIPTION")

  end

  scenario "Removing a meta key from a context" do

    first("a", text: "Edit").click

    expect(all("table tbody tr").size).to eq(8)

    first("a", text: "Remove").click

    expect(page).to have_css(".alert-success")
    expect(all("table tbody tr").size).to eq(7)

  end

  scenario "Displaying media sets on a separate page" do

    find("table tbody a", text: "Media Sets", match: :first).click

    expect(current_path).to match("^/app_admin/contexts/.+/media_sets$")
    expect(find("table tbody").all("tr.success, tr.danger").size).to be > 0
    all("table tbody tr").each do |row|
      expect{row.find('a')}.not_to raise_error
      expect(row.find('a')[:href]).to match(/^\/sets\/.+$/)
    end

  end

  scenario "Displaying links to related meta keys" do

    first("a", text: "Edit").click

    all('table tbody tr').each do |row|
      expect{ row.find('.meta-key-link') }.not_to raise_error
    end

    meta_key_link = find(".meta-key-link", match: :first)
    meta_key = MetaKey.find(meta_key_link.text)
    meta_key_link.click

    expect(current_path).to eq(edit_app_admin_meta_key_path(meta_key))

  end
end
