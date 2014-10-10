require 'spec_helper'

describe MediaSetsController do
  include Controllers::Shared
  render_views
  
  before :each do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    @media_set = FactoryGirl.create :media_set, :user => @user
    3.times { @media_set.child_media_resources << FactoryGirl.create(:media_entry_with_image_media_file, :user => @user) }
  end
  
  
  context "fetch a media set with children" do
  
    # done for the splash screen image slideshow
    it "should return a media set with its children with nested images as base64"  do
      get :show, {:format => :json, :id => @media_set.id, :with => {:children => {:type => "media_entries",
                                                                                  :with => {:image => {:as => "base64"}}},
                                                                    :image => {:as => "base64", :size => "small"}}}, valid_session(@user)
      json = JSON.parse(response.body)
      expect(json["id"]).to be== @media_set.id
      expect(json["children"].keys.sort).to eq ["media_resources", "pagination"]
      expect(json["children"]["pagination"].keys.sort).
        to eq ["page", "per_page", "total", "total_media_entries", "total_media_sets", "total_pages"]
      json["children"]["media_resources"].each do |child|
        expect(child["id"]).not_to be_blank
        expect(child["image"]).not_to be_blank
      end
    end
  end
end
