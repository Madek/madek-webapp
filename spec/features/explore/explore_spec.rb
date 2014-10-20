require "spec_helper"
require "spec_helper_feature"
require "spec_helper_feature_shared"


feature "Visiting explore main page" do
  scenario "Teaser set images should be randomized" do
    srand 123
    visit '/explore'
    within("#teaser-set") do
      @img1 = first(".ui-collage-item")['href']

    end
    visit '/explore'
    within("#teaser-set") do
      img2 = first(".ui-collage-item")['href']
      expect(@img1).not_to eq img2
    end
  end
end
