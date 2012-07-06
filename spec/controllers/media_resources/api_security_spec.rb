require 'spec_helper'

describe MediaResourcesController do
  render_views


  describe "Requesting json of a set with children not owned by the requesting user" do

    before :each do
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


    let :request do
      get :index, {format: 'json',ids: [@set.id], with: {children: true}}, {user_id: @user_b.id}
    end

    let :resources do
      request()
      resources = JSON.parse(response.body)['media_resources']
      puts resources
      resources
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
        Userpermission.create user: @user_b, media_resource: @set
      end

      describe "the response" do

        let :extract_set do
          resources.detect{|x| x['id']==@set.id}
        end

        it "should contain the set" do
          extract_set.should_not be_empty
        end

        describe "the children of the set" do
          let :children do
            extract_set['children']
          end

          it "should be empty" do
            children.should be_empty
          end

        end

      end

    end

  end

end
 

