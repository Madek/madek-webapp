require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Welcome page" do
  scenario "Elements of weclome page" do
    visit root_path
    expect( find("#teaser-set").all("img").size).to be > 0
    expect( find("#catalog .grid").all("li.ui-resource").size ).to be > 0
    expect( find("#catalog .grid").all("li.ui-resource").size ).to be < 3
    expect( find("#featured-set .grid").all("li.ui-resource").size ).to be > 0
    expect( find("#latest-media-entries .grid").all("li.ui-resource").size ).to be > 0
    expect(find "#database-user" ).to be
    expect(find "a#to-explore").to be
    expect(find "a#to-help").to be

    visit root_path
    all("#catalog a")[0].click
    expect(find ".view-explore-catalog").to be

    visit root_path
    find("a#to-explore").click
    expect(current_path).to eq "/explore"
    
    visit root_path
    all("#featured-set a")[0].click
    expect(current_path).to eq "/explore/featured_set"
     
  end
  
  scenario "Catalog feauture" do
    visit root_path
    all("#catalog a")[0].click
    expect(find ".view-explore-catalog").to be
    all(".ui-resources")[0].click
    expect(all("ul.ui-resources li.ui-resource").size).to be > 1
  end
end
