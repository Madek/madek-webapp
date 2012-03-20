require 'spec_helper'

describe MediaResourcesController do

  before :all do
    @user = FactoryGirl.create :user
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
