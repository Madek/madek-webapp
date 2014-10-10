require 'spec_helper'

describe UsersController do
  include Controllers::Shared
  render_views

  before :each do
    FactoryGirl.create :usage_term
    @normin = FactoryGirl.create :user, login: "normin"
    @adam= FactoryGirl.create :user, login: "adam", 
      person: FactoryGirl.create(:person, first_name: "Adam"  )

    @group = Group.create name: "Some Group"
    @group.users << @adam
    @group.users << @normin

    @group2 = Group.create name: "Another Group"
  end

  describe "GET index" do
    context "as JSON" do
      it "should find all users" do
        get :index, {format: :json}, valid_session(@normin)
        json = JSON.parse(response.body)
        expected = User.all.map {|x| {"id" => x.id, "name" => x.to_s, "login" => x.login}}
        expect(json | expected).to eql(json & expected)
      end

      it "should find matching users" do
        get :index, {format: :json, query: "adam"}, valid_session(@normin)
        json = JSON.parse(response.body)
        expected = [{"id" => @adam.id, "name" => @adam.to_s, "login" => @adam.login}]
        expect(json | expected).to eql(json & expected)
      end

    end
  end

end

