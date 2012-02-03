require 'spec_helper'

describe "/media_sets", :type => :api do

  context "im NOT logged in or authenticated" do
  
    it "should return the public splashscreen media_set containing its media_entries with author, image and title"  do
      media_set = Factory(:media_set, :view => true)
      AppSettings.splashscreen_slideshow_set_id = media_set.id
      get "/media_sets/#{media_set.id}", :format => :json, :with => {:media_set => {:media_entries => {:author => true, :title => true, :image => {:size => "large"}}}}
      last_response.body.should_not match /redirected/
      json = JSON.parse(last_response.body)
      json["id"].should == media_set.id
      json["media_entries"].size.should == media_set.media_entries.size
      
      json["media_entries"].each do |media_entry|
        media_entry["id"].blank?.should_not == true
        media_entry["image"].blank?.should_not == true
        media_entry["author"].blank?.should_not == true
        media_entry["title"].blank?.should_not == true
      end
    end
  end
  
  context "im logged in or authenticated" do
    let(:user) {
      user = FactoryGirl.create :user, :login => "spec", :password => Digest::SHA1.hexdigest("spec")
      post "/db/login", {:login => user.login, :password => "spec"}
      get "/"
      last_response.body.should_not match /Invalid username\/password/
      user
    }
    
    it "should return media_resources of the child_set with images"  do
      parent_media_set = Factory(:media_set, :view => true, :user => user)
      (1..5).each do
         parent_media_set.media_entries << Factory(:media_entry, :view => true, :user => user)
         media_set = Factory(:media_set, :view => true, :user => user)
         media_set.media_entries << Factory(:media_entry, :view => true, :user => user)
         parent_media_set.child_sets << media_set
      end
      
      get "/media_sets/#{parent_media_set.id}", :format => :json, :with => {:media_set => {:media_resources => {:type => 1, :image => {:as => "base64", :size => "small"}}}}
      json = JSON.parse(last_response.body)

      json["id"].should == parent_media_set.id
      json["media_resources"].size.should == parent_media_set.media_entries.size+parent_media_set.child_sets.size
      
      json["media_resources"].each do |entry|
        entry["id"].blank?.should_not == true
        entry["image"].blank?.should_not == true
        entry["type"].blank?.should_not == true
      end
    end
  end
end
