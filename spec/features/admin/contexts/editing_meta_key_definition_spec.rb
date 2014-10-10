require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Contexts" do

  feature "Editing a meta key definition" do

    background { sign_in_as "adam" }
    
    scenario "when the meta key is of the same type" do

      visit "/app_admin/contexts/copyright/edit"
      first("a", text: "Edit").click
      select "version", from: "meta_key_definition[meta_key_id]"
      find("input[type='submit']").click

      expect(page).to have_css(".alert-success")
      expect(current_path).to match("/app_admin/contexts/copyright/meta_key_definitions/[^/]+/edit")

      find("input[type='submit']").click

      expect(page).to have_css(".alert-success")
      expect(current_path).to match("/app_admin/contexts/copyright/edit$")
    end

    scenario "when the meta key is different type" do

      visit "/app_admin/contexts/copyright/edit"
      first("a", text: "Edit").click
      select "author", from: "meta_key_definition[meta_key_id]"
      find("input[type='submit']").click

      expect(page).to have_css(".alert-success")
      expect(current_path).to eq("/app_admin/contexts/copyright/edit")
    end
  end
end
