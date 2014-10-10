require 'spec_helper'

describe MediaResourcesController, type: :controller do
  include Controllers::Shared
  render_views

  before :each do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :context_core
    @user_a = FactoryGirl.create :user
    @user_b = FactoryGirl.create :user
    @set = FactoryGirl.create :media_set, user: @user_a
    @entry_1 = FactoryGirl.create :media_entry, user: @user_a
    @entry_2 = FactoryGirl.create :media_entry, user: @user_a
    @set.child_media_resources << @entry_1
    @set.child_media_resources << @entry_2
  end



  describe "Requesting json of a set with children not owned by the requesting user" do


    let :request do
      get :index, {format: 'json', ids: [@set.id], with: {children: true}}, valid_session(@user_b)
    end

    let :resources do
      request
      JSON.parse(response.body)['media_resources']
    end


    it "should be successful" do
      request
      expect(response).to be_success
    end


    it "should not contain any media_resources" do
      expect(resources).to be_empty
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
          expect(extract_set).not_to be_empty
        end

        describe "the children of the set" do

          it "should be empty" do
            expect(children['media_resources']).to be_empty
          end

        end

      end

      context "The requester has view permission on exactly one child through a userpermission" do
        before :each do
          Userpermission.create user: @user_b, media_resource: @entry_1, view: true
        end
        describe "the response" do
          it "should exactly contain this child" do
            expect(
              children['media_resources'].detect { |res| res['id'] == @entry_1.id }
            ).not_to be_empty
            expect(children['media_resources'].size).to be== 1
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
            expect(
              children['media_resources'].detect { |res| res['id'] == @entry_1.id }
            ).not_to be_empty
            expect(children['media_resources'].size).to be== 1
          end
        end
      end

    end

  end

end
