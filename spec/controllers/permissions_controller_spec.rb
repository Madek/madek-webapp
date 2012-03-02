require 'spec_helper'

describe PermissionsController do

  before :all do
    @user = Factory :user
  end

  describe "an index of permissions for a single resource" do
    before :each do
      @media_resource = Factory :media_resource, :user => @user
    end

    it "should respond with success, only with public and you keys" do
      get :index, {format: 'json', media_resource_ids: [@media_resource.id] }, {user_id: @user.id}
      response.should be_success
      json = JSON.parse(response.body)
      expected = {"public"=>{"view"=>[], "edit"=>[], "download"=>[]},
                  "you"=>{"view"=>[@media_resource.id], "edit"=>[@media_resource.id], "download"=>[@media_resource.id], "manage"=>[@media_resource.id]}}
      json.eql?(expected).should be_true
      pending
    end
  end

  describe "an index of permissions for multiple resources" do
    before :each do
      @media_resources = []
      @media_resources << (Factory :media_resource, :user => @user)
      @media_resources << (Factory :media_resource, :user => @user)
      @media_resources << (Factory :media_resource, :user => @user)
    end

    it "should respond with success" do
      get :index, {format: 'json', media_resource_ids: @media_resources.map(&:id) }, {user_id: @user.id}
      response.should be_success
      json = JSON.parse(response.body)
      expected = {"public"=>{"view"=>[], "edit"=>[], "download"=>[]},
                  "you"=>{"view"=>[6179], "edit"=>[6179], "download"=>[6179], "manage"=>[6179]},
                  "users"=>[{"id"=>159123, "name"=>"Sellitto, Franco", "view"=>[6179], "edit"=>[6179], "download"=>[6179], "manage"=>[6179]}],
                  "groups"=>[{"id"=>1519, "name"=>"MAdeK-Team", "view"=>[6179], "edit"=>[6179], "download"=>[6179]}]}
      json.eql?(expected).should be_true
      pending
    end
  end

end

#      app.get "/permissions.json", {media_resource_ids: [6179, 7763, 26911, 26891, 25717], with: {users: true, groups: true}}      