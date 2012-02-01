require 'spec_helper'

describe "/media_sets", :type => :api do

  context "im NOT logged in or authenticated" do
  
    it "should return the public splashscreen media_set containing its media_entries", do
      media_set = Factory(:media_set, :view => true)
      AppSettings.splashscreen_slideshow_set_id = media_set.id
      get "/media_sets/#{media_set.id}", :format => :json, :options_for_media_entries => {:show => true}, :with => {:media_entries => {:author => 1}}
      last_response.body.should_not match /redirected/
      JSON.parse(last_response.body)["id"].should be media_set.id
    end
  end
  
  context "im logged in or authenticated" do
  end
end
