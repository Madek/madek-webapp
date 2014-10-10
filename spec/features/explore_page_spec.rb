require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Explore Page" do
  scenario "Elements of welcome page", browser: :headless do
    visit root_path
    click_on_the_explore_tab
    
    #Teaser set visible
    expect( find("#teaser-set").all("img").size).to be > 0
    
    #Catalog visible
    expect( find("#catalog .grid").all("li.ui-resource").size ).to be > 0
    expect( find("#catalog .grid").all("li.ui-resource").size ).to be < 3
    
    #Featured set visible
    expect( find("#featured-set .grid").all("li.ui-resource").size ).to be > 0

    assert_exact_url_path "/explore"
    expect(page).to have_content "Häufige Schlagworte"
  end
  
  def click_on_the_explore_tab
    find("a#to-explore").click
  end
end
