require 'spec_helper'

describe PermissionsController do

  before :all do
    @user = Factory :user
  end

  before :each do
    @media_resource = Factory :media_resource, :user => @user
  end

  describe "an index of permissions of a single resource" do
    it "should respond with success" do
      get :index, {format: 'json', media_resource_ids: [@media_resource.id] }, {user_id: @user.id}
      response.should be_success
      json = JSON.parse(response.body)
      
      pending
    end
  end

end
