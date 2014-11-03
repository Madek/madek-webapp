require "spec_helper"
require "spec_helper_feature"
require "spec_helper_feature_shared"


sektion_klang = '#a290eeeb-cc34-4487-9149-a897b5830d49'
catalog_schlagworte = '/explore/catalog/ddf90877-4dd9-48e9-8cf1-b146ed7ebe69'

feature "Visiting catalog categories" do
  scenario "Preview image for category should be randomized" do
    srand 123

    visit catalog_schlagworte
    within(sektion_klang) do
      @img1 = find(".ui-thumbnail-image")['src']
    end

    visit catalog_schlagworte
    within(sektion_klang) do
      img2 = find(".ui-thumbnail-image")['src']
      expect(@img1).not_to eq img2
    end
  end
end
