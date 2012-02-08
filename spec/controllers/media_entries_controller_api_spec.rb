require 'spec_helper'

describe MediaEntriesController do

context "API" do

  before :all do
    @user = FactoryGirl.create :user
  end
  
  context "request with authenticated session (user_id)" do
    before :all do 
      @user = FactoryGirl.create :user
      @parent_media_set = Factory(:media_set, :view => true, :user => @user)
      (1..5).each { @parent_media_set.media_entries << Factory(:media_entry, :view => true, :user => @user) }
    end
    
    let(:session) do
      {user_id: @user.id}
    end
    
    it "should return media entries scoped trough a given parent set together with images as base 64" do
      get :index, {format: :json, :parent_ids => [@parent_media_set.id], :with => {:media_resource => {:image => {:as => "base64", :size => "small"}}}}, session
      json = JSON.parse(response.body)
        json.size.should == 5
        
        json.each do |media_entry|
          media_entry["id"].blank?.should_not == true
          media_entry["image"].blank?.should_not == true
        end
    end
    end
  end
end
