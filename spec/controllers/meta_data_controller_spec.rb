require 'spec_helper'

describe MetaDataController do
  render_views


  before :all do
    @user = FactoryGirl.create :user
    @media_set= FactoryGirl.create :media_set, user: @user
    @media_set.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
    @title_meta_datum =  @media_set.meta_data.joins(:meta_key).where("meta_keys.label = ?","title").first
  end

  let :valid_session do
    {:user_id => @user.id}
  end


  let :get_json_as_hash do
    get :index, {format: 'json', media_set_id: @media_set.id}, valid_session
    JSON.parse(response.body)
  end

  describe "PUT" do

    it "should update a title value" do
      put :update, {id: @title_meta_datum.id, meta_datum: {value: "BLAH"}}, valid_session
      @title_meta_datum.reload.value.should == "BLAH"
    end

    it "should not update meta_data if the user doesn't have manage permissions" do
      other_user = FactoryGirl.create :user
      other_media_set= FactoryGirl.create :media_set, user: other_user
      other_media_set.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
      other_title_meta_datum =  other_media_set.meta_data.joins(:meta_key).where("meta_keys.label = ?","title").first

      put :update, {id: other_title_meta_datum.id, meta_datum: {value: "BLAH"}}, valid_session
      response.should_not  be_success
      other_title_meta_datum.reload.value.should_not  == "BLAH"

    end

    it "should not be possible to change the media_resource_id " do
      other_user = FactoryGirl.create :user
      other_media_set= FactoryGirl.create :media_set, user: other_user
      put :update, {id: @title_meta_datum.id, meta_datum: {media_resource_id: other_media_set.id}}, valid_session
      response.should_not  be_success
      @title_meta_datum.reload.media_resource_id.should_not == @media_set.id
    end

  end

  describe "JSON GET Response" do

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

  after :all do
    @user.destroy
    @user.person.destroy
    @media_set.destroy
  end

end
