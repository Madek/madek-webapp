require 'spec_helper'

describe MetaContextGroupsController do

  render_views

  before :all do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    meta_context_group = FactoryGirl.create :meta_context_group
    @meta_context_groups = MetaContextGroup.all
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
      assigns(:meta_context_groups).should eq(@meta_context_groups)
    end

    it "should set the correct json content" do
      get_index
      json = JSON.parse response.body
      expected = MetaContextGroup.all.as_json
      json.eql?(expected).should be_true
    end

  end


end
