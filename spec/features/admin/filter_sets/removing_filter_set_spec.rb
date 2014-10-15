require "spec_helper_feature"

feature "Admin - Filter Sets" do

  scenario "Deleting a filter set", browser: :headless do

    @admin = sign_in_as 'adam'
    @media_resource = MediaResource.find_by_title("Schlagworte")

    expect(@media_resource.type).to eq("FilterSet")

    visit "/app_admin"
    find(".dropdown a", text: "Media Resources").click
    find(".dropdown-menu a", text: "Filter Sets", visible: true).click

    expect(current_url).to match("/app_admin/filter_sets")
    expect(page).to have_content("Schlagworte")
    find("table tr", text: "Schlagworte").find("a", text: "Delete").click

    expect(page).not_to have_content("Schlagworte")

    expect(page).to have_css(".alert-success")
    expect{ MediaResource.find(@media_resource.id) }.to raise_error
  end

end
