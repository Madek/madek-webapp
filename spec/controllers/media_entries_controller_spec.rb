require 'spec_helper'
require 'pry'

describe MediaEntriesController do

  before :all do
    @user = FactoryGirl.create :user
    @media_set = Factory(:media_set, :view => true, :user => @user)
    (1..5).each { @media_set.media_entries << Factory(:media_entry, :view => true, :user => @user) }
  end

  describe "GET index in JSON format" do

    it "should respond with success" do
      get :index, {:format => 'json'}, {:user_id => @user.id}
      response.should  be_success
    end

    it "should return media entries scoped trough a given parent set together with images as base 64"  do
     
      get :index, {:format => :json, :parent_ids => Array(@media_set.id), :with => {:media_resource => {:image => {:as => "base64", :size => "small"}}}}, {:user_id => @user.id}
      json = JSON.parse(response.body)
      json.size.should == 5
      
      json.each do |media_entry|
        media_entry["id"].blank?.should_not == true
        media_entry["image"].blank?.should_not == true
      end

    end

  end

end
