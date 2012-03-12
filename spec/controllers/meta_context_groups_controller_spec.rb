require 'spec_helper'

describe MetaContextGroupsController do

  render_views

  before :all do
    @user = Factory :user
    @meta_context_group = FactoryGirl.create :meta_context_group
  end

  def valid_session
    {user_id: @user.id}
  end


  describe "GET index" do

    let :get_index do
      get :index, {format: 'json'}, valid_session
    end

    it "should be successful" do
      get_index
      response.should be_success
    end

    it "should assign @meta_context_groups" do
      get_index
      assigns(:meta_context_groups).should eq([@meta_context_group])
    end

    it "should set the correct json content" do
      get_index
      json = JSON.parse response.body
      json[0]["id"].should == @meta_context_group.id
      json[0]["name"].should == @meta_context_group.name
    end

  end


end
