require 'spec_helper'

describe PermissionsController do
  render_views

  before :all do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
  end

  describe "an index of permissions for a single resource" do

    before :all do
      @media_resource = FactoryGirl.create :media_resource, :user => @user
    end

    it "should respond with success, only with public and you keys" do
      get :index, {format: 'json', media_resource_ids: [@media_resource.id] }, {user_id: @user.id}
      response.should be_success
      json = JSON.parse(response.body)
      expected = {"public"=>{"view"=>[], "edit"=>[], "download"=>[]},
                  "you"=>{"id"=> @user.id, "name"=>"#{@user.to_s}",
                          "view"=>[@media_resource.id], "edit"=>[@media_resource.id], "download"=>[@media_resource.id], "manage"=>[@media_resource.id]}
                  }
      json.eql?(expected).should be_true
    end

  end

  describe "an index of permissions for multiple resources, with users and groups" do

    before :all do
      @user_a = FactoryGirl.create :user
      @group_a = FactoryGirl.create :group
      @media_resources = 3.times.map do
        mr = FactoryGirl.create :media_resource, :user => @user
        mr.userpermissions.create(user: @user_a, view: true, edit: true, download: true, manage: false)
        mr.grouppermissions.create(group: @group_a, view: true, edit: false, download: false, manage: false)
        mr
      end
    end

    it "should respond with success" do
      media_resource_ids = @media_resources.map(&:id)
      get :index, {format: 'json', media_resource_ids: media_resource_ids, with: {users: true, groups: true} }, {user_id: @user.id}
      response.should be_success
      json = JSON.parse(response.body)
      expected = {"public"=>{"view"=>[], "edit"=>[], "download"=>[]},
                  "you"=> {"id"=> @user.id, "name"=>"#{@user.to_s}",
                           "view"=> media_resource_ids, "edit"=> media_resource_ids, "download"=> media_resource_ids, "manage"=> media_resource_ids},
                  "users"=>[{"id"=> @user_a.id, "name"=>"#{@user_a.to_s}",
                             "view"=> media_resource_ids, "edit"=> media_resource_ids, "download"=> media_resource_ids, "manage"=>[]}],
                  "groups"=>[{"id"=> @group_a.id, "name"=>"#{@group_a.to_s}",
                             "view"=> media_resource_ids, "edit"=> [], "download"=> []}]
                  }
      json.eql?(expected).should be_true
    end

  end


  describe "PUTing on /permissions/" do

    before :all do
      @user_a = FactoryGirl.create :user
      @user_b = FactoryGirl.create :user
      @group_a = FactoryGirl.create :group
      @group_b = FactoryGirl.create :group
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

    describe "creating a new userpermissions " do
      it "should create a new userpermission if none exists" do
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should == 0
        put :update, {format: 'json',media_resource_ids: [@mr1.id],users: [{id: @user_b.id,view: nil, download: true, manage:false  }]}, {user_id: @user_a.id}
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should >= 1
      end
    end

    describe "updating a userpermission " do
      before :each do
        Userpermission.create user: @user_b, media_resource: @mr1
      end
      it "should update a uerspermission " do
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should == 1
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).first.view.should == false
        put :update, {format: 'json',media_resource_ids: [@mr1.id],users: [{id: @user_b.id, view: true, download: nil, manage:""}]}, {user_id: @user_a.id}
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should == 1
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).first.view.should == true
      end
    end


    describe "deleting groups that have a grouppermission but are not in the set of groups " do 
      before :each do
        Grouppermission.create group: @group_a, media_resource: @mr1
        Grouppermission.create group: @group_b, media_resource: @mr1
      end
      it "should delete the gouppermission of @group_a" do
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_a.id).size.should >= 1
        put :update, {format: 'json',media_resource_ids: [@mr1.id],groups: [{id: @group_b.id}]}, {user_id: @user_a.id}
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_a.id).size.should == 0
      end
    end


    describe "creating a new grouppermission" do
      it "should create a new grouppermission if none exists" do
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).size.should == 0
        put :update, {format: 'json',media_resource_ids: [@mr1.id],groups: [{id: @group_b.id,view: nil, download: true, manage:false  }]}, {user_id: @user_a.id}
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).size.should >= 1
      end
    end


    describe "updating a grouppermission " do
      before :each do
        Grouppermission.create group: @group_b, media_resource: @mr1
      end
      it "should update a grouppermission " do
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).size.should == 1
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).first.view.should == false
        put :update, {format: 'json',media_resource_ids: [@mr1.id],groups: [{id: @group_b.id, view: true, download: nil, manage:""}]}, {user_id: @user_a.id}
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).size.should == 1
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).first.view.should == true
      end
    end


    describe "updating public permissions with put" do
      it "should update the view view permission to true" do
        MediaResource.find(@mr1.id).view.should == false
        put :update, {format: 'json',media_resource_ids: [@mr1.id],public: {view: true, download: nil, manage:""}}, {user_id: @user_a.id}
        MediaResource.find(@mr1.id).view.should == true
      end
    end

    describe "setting a new owner" do
      it "should belong to the new owner afterwards" do
        MediaResource.find(@mr1.id).user_id.should == @user_a.id
        put :update, {format: 'json',media_resource_ids: [@mr1.id],owner: @user_b.id}, {user_id: @user_a.id}
        MediaResource.find(@mr1.id).user_id.should == @user_b.id
      end
    end

  end

end
