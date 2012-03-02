require 'spec_helper'

describe PermissionsController do
 
#  before :all do
#    @user = Factory :user
#  end
#
#  before :each do
#    @media_resource = Factory :media_resource, :user => @user
#  end
#
#  describe "an index of permissions of a single resource" do
#    it "should respond with success" do
#      get :index, {format: 'json', media_resource_ids: [@media_resource.id] }, {user_id: @user.id}
#      response.should be_success
#      json = JSON.parse(response.body)
#      
#      pending
#    end
#  end
#


  context "PUTing on /permissions/" do

    before :all do
      @user_a = FactoryGirl.create :user
      @user_b = FactoryGirl.create :user
      @mr1 = FactoryGirl.create :media_resource, user: @user_a
      @mr2 = FactoryGirl.create :media_resource, user: @user_a
      @mr3 = FactoryGirl.create :media_resource, user: @user_a
    
    end

    describe "deleting users that have a userpermission but not in the set of users " do 

      before :each do
        Userpermission.create user: @user_a, media_resource: @mr1
        Userpermission.create user: @user_b, media_resource: @mr1
      end
        
      it "should delete the up of @user_a" do

        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_a.id).size.should >= 1

        put :update, {format: 'json',media_resource_ids: [@mr1.id],users: [{id: @user_b.id,view: nil, download: true, manage:false  }]}, {user_id: @user_a.id}

        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_a.id).size.should == 0

      end

    end

  end

end
