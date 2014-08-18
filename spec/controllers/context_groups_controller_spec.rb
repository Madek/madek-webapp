require 'spec_helper'

describe ContextGroupsController do
  include Controllers::Shared

  render_views

  before :each do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    context_group = FactoryGirl.create :context_group
    @context_groups = ContextGroup.all
  end


  describe "GET index" do

    let :get_index do
      get :index, {format: 'json'}, valid_session(@user)
    end

    it "should be successful" do
      get_index
      response.should be_success
    end

    it "should set the correct json content" do
      get_index
      json = JSON.parse(response.body)
      expected = @context_groups.as_json
      json.eql?(expected).should be_true
    end

  end


end
