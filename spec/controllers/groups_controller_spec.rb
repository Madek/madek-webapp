require 'spec_helper'

describe GroupsController do
  include Controllers::Shared
  render_views
  
  before :each do
    FactoryGirl.create :usage_term
    @normin = FactoryGirl.create :user, login: "normin"
    @adam= FactoryGirl.create :user, login: "adam"

    @meta_dep = InstitutionalGroup.create name: "LDAP Group"
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
        get :index, {format: :json}, valid_session(@normin)
        json = JSON.parse(response.body)
        ["type", "id", "name"].all? { |k| expect(json.first.keys).to include(k) }
      end

      it "should find matching groups" do
        get :index, {format: :json, query: "another group"}, valid_session(@normin)
        json = JSON.parse(response.body)
        expect( json.any? {|g| g["name"] == "Another Group"} ).to be true
      end
    end
  end

  describe "GET show" do
    describe "include users" do
      it "should set @include_users to true" do
        get :show, {format: :json, id: @group.id, include_users: true}, valid_session(@normin)
        expect(assigns(:include_users)).to be true
      end

      describe "request group by normin" do
        it "should assign the @users to include adam" do 
          get :show, {format: :json, id: @group.id, include_users: true}, valid_session(@normin)
          json = JSON.parse(response.body)
          expect(json["users"].map { |x| x["id"] }).to include(@adam.id)
        end

        describe "the response" do
          let :json_body do
            get :show, {format: :json, id: @group.id, include_users: true}, valid_session(@normin)
            JSON.parse(response.body)
          end

          it "should include 2 users" do
            expect(json_body['users'].size).to eq 2
          end

          it "should include the :id of the users" do
            expect( json_body['users'][0]['id']).not_to be_nil
          end

          it "should include the :last_name of the users" do
            expect( json_body['users'][0]['last_name']).not_to be_nil
          end
        end
      end

      describe "request departement by normin"  do
        it "should return an empty user array" do
          get :show, {format: :json, id: @meta_dep.id, include_users: true}, valid_session(@normin)
          json = JSON.parse(response.body)
          expect(json["users"]).to eq []
        end
      end
    end
  end

end

