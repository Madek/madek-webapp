require 'spec_helper'

describe GroupsController do

  before :all do
    @normin = PersonaFactory.create :normin
    @adam= PersonaFactory.create :adam

    @meta_dep = MetaDepartment.create name: "LDAP Group"
    @meta_dep.users << @adam
    @meta_dep.users << @normin

    @group = Group.create name: "Some Group"
    @group.users << @adam
    @group.users << @normin
  end

  describe "GET show" do

    describe "include users" do

      describe "request group" do

        it "should assign the @users to include adam" do 
          get :show, {id: @group.id, include_users: true}, {user_id: @normin}
          assigns(:users).should include @adam
        end

      end

    end

  end

end

