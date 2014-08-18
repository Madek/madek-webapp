require 'spec_helper'

describe PermissionsController do
  include Controllers::Shared
  render_views

  before :each do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
  end

  describe "an index of permissions for a single resource" do

    before :each do
      @media_resource = FactoryGirl.create :media_resource, :user => @user
    end

    it "should respond with success, only with public and you keys" do
      get :index, {format: 'json', media_resource_ids: [@media_resource.id] }, valid_session(@user)
      response.should be_success
      json = JSON.parse(response.body).deep_symbolize_keys
      expected = {public:{view:[], edit:[], download:[]},
                  you:{id: @user.id, name:"#{@user.to_s}",
                       view:[@media_resource.id], 
                       edit:[@media_resource.id], 
                       download:[@media_resource.id], 
                       manage:[@media_resource.id]}
      }
      expect(json[:public].deep_symbolize_keys).to be== expected[:public]
      #json.eql?(expected).should be_true
    end

  end

  describe "an index of permissions for multiple resources, with users and groups" do

    before :each do
      @user_a = FactoryGirl.create :user
      @group_a = FactoryGirl.create :group
      @application = FactoryGirl.create :application, user: @user
      @media_resources = 1.times.map do
        mr = FactoryGirl.create :media_resource, :user => @user
        mr.userpermissions.create(user: @user_a, view: true, edit: true, download: true, manage: false)
        mr.grouppermissions.create(group: @group_a, view: true, edit: false, download: false, manage: false)
        mr.applicationpermissions.create!(application: @application, view: true, download: false)
        mr
      end
    end

    it "should respond with success and contain the proper data" do
      media_resource_ids = @media_resources.map(&:id)
      get :index, {format: 'json', media_resource_ids: media_resource_ids, with: {users: true, groups: true} }, valid_session(@user)
      response.should be_success
      response_data = JSON.parse(response.body).deep_symbolize_keys
      expected = {public:{view:[], edit:[], download:[]},
                  you: {id: @user.id, name:"#{@user.to_s}",
                           view: media_resource_ids, 
                           edit: media_resource_ids, 
                           download: media_resource_ids, 
                           manage: media_resource_ids},
                  users:[{id: @user_a.id, name:"#{@user_a.to_s}",
                             view: media_resource_ids, 
                             edit: media_resource_ids, 
                             download: media_resource_ids, 
                             manage:[]}],
                  groups:[{id: @group_a.id, 
                           name:"#{@group_a.to_s}",
                           view: media_resource_ids, 
                           edit: [], 
                           download: []}],
                  applications:[{id: @application.id,
                                 description: @application.description,
                                 view: media_resource_ids,
                                 download: [] }]}

      expect(response_data.keys).to be== expected.keys
      expect(response_data[:public].deep_symbolize_keys).to be== expected[:public]
      expect(response_data[:you].deep_symbolize_keys).to be== expected[:you]
      expect(response_data[:users].map(&:deep_symbolize_keys)).to be== expected[:users]
      expect(response_data[:groups].map(&:deep_symbolize_keys)).to be== expected[:groups]
      expect(response_data[:applications].map(&:deep_symbolize_keys)).to be== expected[:applications]
    end

  end


  describe "PUTing on /permissions/" do

    before :each do
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
        put :update, {format: 'json',media_resource_ids: [@mr1.id],users: [{id: @user_b.id,view: nil, download: true, manage:false  }]}, valid_session(@user_a)
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_a.id).size.should == 0
      end
    end

    describe "creating a new userpermissions " do
      it "should create a new userpermission if none exists" do
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should == 0
        put :update, {format: 'json',media_resource_ids: [@mr1.id],users: [{id: @user_b.id,view: nil, download: true, manage:false  }]}, valid_session(@user_a)
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should >= 1
      end
    end

    describe "updating a userpermission " do
      before :each do
        Userpermission.create user: @user_b, media_resource: @mr1
      end
      it "should update a userpermission " do
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should == 1
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).first.view.should == false
        put :update, {format: 'json',media_resource_ids: [@mr1.id],users: [{id: @user_b.id, view: true, download: nil, manage:""}]}, valid_session(@user_a)
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).size.should == 1
        Userpermission.where("media_resource_id = ?",@mr1.id).where("user_id = ?",@user_b.id).first.view.should == true
      end
    end

    describe "updating a userpermission of a resourche that is not manageable by the cuurent user" do

      before :each do
        Userpermission.create user: @user_b, media_resource: @mr1, view: true, download: true
        @mr1.update_attributes! user: @user_a
      end

      it "should not update the userpermission" do
        Userpermission.where("media_resource_id = ?",@mr1.id) \
          .where("user_id = ?",@user_b.id).size.should == 1
        Userpermission.where("media_resource_id = ?",@mr1.id) \
          .where("user_id = ?",@user_b.id).first.download.should == true
        put :update, {format: 'json', \
          media_resource_ids: [@mr1.id], \
          users: [{id: @user_b.id, download: false}]}, \
          valid_session(@user_a)
        Userpermission.where("media_resource_id = ?",@mr1.id) \
          .where("user_id = ?",@user_b.id).size.should == 1
        Userpermission.where("media_resource_id = ?",@mr1.id) \
          .where("user_id = ?",@user_b.id).first.download.should == false
      end
    end


    describe "deleting groups that have a grouppermission but are not in the set of groups " do 
      before :each do
        Grouppermission.create group: @group_a, media_resource: @mr1
        Grouppermission.create group: @group_b, media_resource: @mr1
      end
      it "should delete the gouppermission of @group_a" do
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_a.id).size.should >= 1
        put :update, {format: 'json',media_resource_ids: [@mr1.id],groups: [{id: @group_b.id}]}, valid_session(@user_a)
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_a.id).size.should == 0
      end
    end


    describe "creating a new grouppermission" do
      it "should create a new grouppermission if none exists" do
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).size.should == 0
        put :update, {format: 'json',media_resource_ids: [@mr1.id],groups: [{id: @group_b.id,view: nil, download: true, manage:false  }]}, valid_session(@user_a)
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
        put :update, {format: 'json',media_resource_ids: [@mr1.id],groups: [{id: @group_b.id, view: true, download: nil, manage:""}]}, valid_session(@user_a)
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).size.should == 1
        Grouppermission.where("media_resource_id = ?",@mr1.id).where("group_id = ?",@group_b.id).first.view.should == true
      end
    end


    describe API::Applicationpermission do

      before :each do
        @app_a= FactoryGirl.create :application, user: @user_a
        @app_b= FactoryGirl.create :application, user: @user_b
      end

      describe "updating an existing application-permission" do
        before :each do
          @app_perm= API::Applicationpermission.create application: @app_a, media_resource: @mr1, view: false
        end
        it "should be successful and update" do
          put :update, 
            {format: 'json', 
             media_resource_ids: [@mr1.id],
             applications: [{id: @app_a.id, view: true, download: nil, manage:""}]}, 
            valid_session(@user_a)
          response.should be_success
          @app_perm.reload.view.should be== true
        end
      end

      describe "creating a new application-permission" do
        it "should be successful and create" do
          @mr1.applicationpermissions.count.should be== 0
          put :update, 
            {format: 'json', 
             media_resource_ids: [@mr1.id],
             applications: [{id: @app_a.id, view: true, download: nil, manage:""}]}, 
            valid_session(@user_a)
          response.should be_success
          @mr1.applicationpermissions.reload.first.view.should be== true
        end
      end

    end


    describe "updating public permissions with put" do
      it "should update the view view permission to true" do
        MediaResource.find(@mr1.id).view.should == false
        put :update, {format: 'json',media_resource_ids: [@mr1.id],public: {view: true, download: nil, manage:""}}, valid_session(@user_a)
        MediaResource.find(@mr1.id).view.should == true
      end
    end

  end

end
