require 'spec_helper'

describe "/media_entries", :type => :api do

  context "im NOT logged in or authenticated" do
  end
  
  context "im logged in or authenticated" do
    
    let(:user) {
      user = FactoryGirl.create :user, :login => "spec", :password => Digest::SHA1.hexdigest("spec")
      post "/db/login", {:login => user.login, :password => "spec"}
      get "/"
      # don't test in let, before .... 
      last_response.body.should_not match /Invalid username\/password/
      user
    }
    
    it "should return media entries scoped trough a given parent set together with images as base 64"  do
      # never create data directly inside it, context .... 
      # this can have strange side effects, in particular w.r.t. cleaning 
      # use before ...
      media_set = Factory(:media_set, :view => true, :user => user)
      (1..5).each { media_set.media_entries << Factory(:media_entry, :view => true, :user => user) }
      
      get "/media_entries", :format => :json, :parent_ids => Array(media_set.id), :with => {:media_resource => {:image => {:as => "base64", :size => "small"}}}
      json = JSON.parse(last_response.body)
      json.size.should == 5
      
      json.each do |media_entry|
        media_entry["id"].blank?.should_not == true
        media_entry["image"].blank?.should_not == true
      end
    end
  end
end
