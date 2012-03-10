require 'spec_helper'

describe MediaResourcesController do
  render_views

  before :all do
    @user = FactoryGirl.create :user
  end

  context "fetch an index of media resources" do
    before :all do
      40.times do
        type = rand > 0.5 ? :media_entry : :media_set
        Factory type, user: @user
      end
    end
    
    describe "as JSON" do
      describe "as guest user" do
        it "should respond with success" do
          get :index, {format: 'json'}
          response.should  be_success
          json = JSON.parse(response.body)
          json.keys.sort.should == ["media_resources", "pagination"]
          json["pagination"].keys.sort.should == ["page", "per_page", "total", "total_pages"]
          json["media_resources"].is_a?(Array).should be_true
          json["media_resources"].size.should <= json["pagination"]["per_page"]
          n = MediaResource.accessible_by_user(User.new).count
          json["pagination"]["total"].should == n
        end
      end
      describe "as logged in user" do
        it "should respond with success" do
          get :index, {format: 'json'}, {user_id: @user.id}
          response.should  be_success
          json = JSON.parse(response.body)
          json.keys.sort.should == ["media_resources", "pagination"]
          json["pagination"].keys.sort.should == ["page", "per_page", "total", "total_pages"]
          json["media_resources"].is_a?(Array).should be_true
          json["media_resources"].size.should <= json["pagination"]["per_page"]
          n = MediaResource.accessible_by_user(@user).count
          json["pagination"]["total"].should == n
        end
      end
    end
  end


  describe "a PUT json request on a single resource" do
    before :each do
      @mei= FactoryGirl.create :media_entry_incomplete, user: @user
    end
    
    describe  'with {type: "MediaEntry"}' do
      it "should convert the resource to a media entry" do
        put :update, {format: 'json', id: @mei.id, media_resource: {type: "MediaEntry"} }, {user_id: @user.id}
        response.should  be_success
        (MediaEntry.exists? @mei.id).should == true
      end
    end

    describe  'with {download: true}' do
      it "should set the public download permisssion to true " do
        put :update, {format: 'json', id: @mei.id, media_resource: {download: true} }, {user_id: @user.id}
        (MediaResource.find @mei.id).download.should == true
      end
    end
  end
end
