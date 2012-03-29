require 'spec_helper'

describe MetaDataController do
  render_views


  before :all do
    @user = FactoryGirl.create :user
    @media_set= FactoryGirl.create :media_set
    @media_set.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
    @title_meta_datum =  @media_set.meta_data.joins(:meta_key).where("meta_keys.label = ?","title").first
  end

  let :session do
    {:user_id => @user.id}
  end


  let :get_json_as_hash do
    get :index, {format: 'json', media_set_id: @media_set.id}, session
    JSON.parse(response.body)
  end

  describe "PUT" do

    it "should update a title value" do
      put :update, {id: @title_meta_datum.id, meta_datum: {value: "BLAH"}}, session
      @title_meta_datum.reload.value.should == "BLAH"
    end

  end

  describe "JSON GET Response" do

    it "should be successful" do
      get :index, {format: 'json', media_set_id: @media_set.id}, session
      response.should  be_success
    end

    it "should contain the correct title meta_datum" do
      json = get_json_as_hash
      json.detect{|e| e["key"] == "title"}.should be
      json.detect{|e| e["key"] == "title"}["type"].should == "String"
      json.detect{|e| e["key"] == "title"}["id"].should_not be_nil
    end

    it "should contain the correct owner meta_datum" do
      json = get_json_as_hash
      json.detect{|e| e["key"] == "owner"}.should be
      json.detect{|e| e["key"] == "owner"}["type"].should == "User"
      json.detect{|e| e["key"] == "owner"}["id"].should be_nil
    end

  end

  after :all do
    @user.destroy
    @user.person.destroy
    @media_set.destroy
  end

end
