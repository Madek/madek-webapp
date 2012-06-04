require 'spec_helper'

describe MetaDataController do
  render_views

  before :each do
    @user = FactoryGirl.create :user
    @other_user = FactoryGirl.create :user
    @media_set= FactoryGirl.create :media_set, user: @user
    @media_set.meta_data.create(type: "MetaDatumString", :meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
    @title_meta_datum =  @media_set.meta_data.joins(:meta_key).where("meta_keys.label = ?","title").first
  end

  let :valid_session do
    {:user_id => @user.id}
  end


  describe "PUT" do

    it "should update a title value" do
      put :update, {media_resource_id: @media_set.id, id: "title", value: "My new title", format: "json"}, valid_session
      response.should be_success
      @media_set.title.should == "My new title"
    end

    it "should not update meta_data if the user doesn't have edit permissions" do
      put :update, {media_resource_id: @media_set.id, id: "title", value: "My new title", format: "json"}, {user_id: @other_user_id}
      response.should_not be_success
    end

  end

  describe "JSON GET Response" do

    let :get_json_as_hash do
      get :index, {format: 'json', media_set_id: @media_set.id}, valid_session
      JSON.parse(response.body)
    end

    it "should be successful" do
      get :index, {format: 'json', media_set_id: @media_set.id}, valid_session
      response.should  be_success
    end

    it "should contain the correct title meta_datum" do
      json = get_json_as_hash
      json.detect{|e| e["name"] == "title"}.should be
      json.detect{|e| e["name"] == "title"}["type"].should == "String"
    end

    it "should contain the correct owner meta_datum" do
      json = get_json_as_hash
      json.detect{|e| e["name"] == "owner"}.should be
      json.detect{|e| e["name"] == "owner"}["type"].should == "User"
    end
  end

end
