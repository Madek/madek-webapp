require 'spec_helper'

describe MetaDataController do
  include Controllers::Shared
  render_views


  before :each do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :context_core
    @user = FactoryGirl.create :user
    @other_user = FactoryGirl.create :user
    @media_set= FactoryGirl.create :media_set, user: @user
    @media_set.meta_data.create(:meta_key => MetaKey.find_by_id("title"), :value => Faker::Lorem.words(4).join(' '))
    @title_meta_datum =  @media_set.meta_data.joins(:meta_key).where(:meta_keys => {id: "title"}).first
  end


  describe "PUT" do

    it "should update a title value" do
      put :update, {media_resource_id: @media_set.id, id: "title", value: "My new title", format: "json"}, valid_session(@user)
      response.should be_success
      @media_set.title.should == "My new title"
    end

    it "should not update meta_data if the user doesn't have edit permissions" do
      put :update, {media_resource_id: @media_set.id, id: "title", value: "My new title", format: "json"}, {user_id: @other_user_id}
      response.should_not be_success
    end

  end

end
