require 'spec_helper'

describe GroupsController do
  render_views
  
  before :all do
    @normin = FactoryGirl.create :user, login: "normin"
    @adam= FactoryGirl.create :user, login: "adam"

    @meta_dep = MetaDepartment.create name: "LDAP Group"
    @meta_dep.users << @adam
    @meta_dep.users << @normin

    @group = Group.create name: "Some Group"
    @group.users << @adam
    @group.users << @normin

    @group2 = Group.create name: "Another Group"
  end

  describe "GET index" do
    context "as JSON" do
      it "should find all groups" do
        get :index, {format: :json}, {user_id: @normin}
        json = JSON.parse(response.body)
        ["type", "id", "name"].all? {|k| json.first.keys.include?(k) }.should be_true
      end

      it "should find matching groups" do
        get :index, {format: :json, query: "another group"}, {user_id: @normin}
        json = JSON.parse(response.body)
        json.any? {|g| g["name"] == "Another Group"}.should be_true
      end
    end
  end

  describe "GET show" do
    describe "include users" do
      it "should set @include_users to true" do
        get :show, {format: :json, id: @group.id, include_users: true}, {user_id: @normin}
        assigns(:include_users).should == true
      end

      describe "request group by normin" do
        it "should assign the @users to include adam" do 
          get :show, {format: :json, id: @group.id, include_users: true}, {user_id: @normin}
          assigns(:users).should include @adam
        end

        describe "the response" do
          let :json_body do
            get :show, {format: :json, id: @group.id, include_users: true}, {user_id: @normin}
            JSON.parse(response.body)
          end

          it "should include 2 users" do
            json_body['users'].size.should == 2
          end

          it "should include the :id of the users" do
            json_body['users'][0]['id'].should_not == nil
          end

          it "should include the :lastname of the users" do
            json_body['users'][0]['lastname'].should_not == nil
          end
        end
      end

      describe "request departement by normin"  do
        it "should return an empty user array" do
          get :show, {format: :json, id: @meta_dep.id, include_users: true}, {user_id: @normin}
          assigns(:users).should eq []
        end
      end
    end
  end

end

