require 'spec_helper'

describe MediaResourcesController do
  render_views

  before :all do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :meta_context_core
    @user_a = FactoryGirl.create :user
    @user_b = FactoryGirl.create :user
    @set = FactoryGirl.create :media_set
    @entry_1 = FactoryGirl.create :media_entry
    @entry_2 = FactoryGirl.create :media_entry
    @set.children << @entry_1
    @set.children << @entry_2
  end



  describe "Requesting json of a set with children not owned by the requesting user" do


    let :request do
      get :index, {format: 'json',ids: [@set.id], with: {children: true}}, {user_id: @user_b.id}
    end

    let :resources do
      request
      JSON.parse(response.body)['media_resources']
    end


    it "should be successful" do
      request()
      response.should be_success
    end


    it "should not contain any media_resources" do
      resources.should be_empty
    end

    context "The requester has view permission on the set" do

      before :each do
        Userpermission.create user: @user_b, media_resource: @set, view: true
      end

      let :extract_set do
        resources.detect{|x| x['id']==@set.id}
      end

      let :children do
        extract_set['children']
      end

      describe "the response" do


        it "should contain the set" do
          extract_set.should_not be_empty
        end

        describe "the children of the set" do

          it "should be empty" do
            children.should be_empty
          end

        end

      end

      context "The requester has view permission on exactly one child through a userpermission" do
        before :each do
          Userpermission.create user: @user_b, media_resource: @entry_1, view: true
        end
        describe "the response" do
          it "should exactly contain this child" do
            children['media_resources'].detect{|res| res['id']==@entry_1.id}.should_not be_empty
            children['media_resources'].size.should == 1
          end
        end
      end

      context "The requester has view permission on exactly one child through a grouppermission" do
        before :each do
          @group = FactoryGirl.create :group
          @group.users << @user_b
          Grouppermission.create group: @group, media_resource: @entry_1, view: true
        end
        describe "the response" do
          it "should exactly contain this child" do
            children['media_resources'].detect{|res| res['id']==@entry_1.id}.should_not be_empty
            children['media_resources'].size.should == 1
          end
        end
      end

      context "The requester has view permission on exactly one child through a grouppermission but is denied though a userpermission" do
        before :each do
          @group = FactoryGirl.create :group
          @group.users << @user_b
          Grouppermission.create group: @group, media_resource: @entry_1, view: true
          Userpermission.create user: @user_b, media_resource: @entry_1, view: false
        end
        describe "the response" do
          it "should contain no children" do
            children['media_resources'].should be_empty
          end
        end
      end



    end

  end

end
 

