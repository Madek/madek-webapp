require 'spec_helper'

describe UsersController do
  render_views
  
  before :all do
    @normin = FactoryGirl.create :user, login: "normin"
    @adam= FactoryGirl.create :user, login: "adam", 
      person: FactoryGirl.create(:person, firstname: "Adam"  )

    @group = Group.create name: "Some Group"
    @group.users << @adam
    @group.users << @normin

    @group2 = Group.create name: "Another Group"
  end

  let :session do
    {user_id: @normin.id}
  end

  describe "GET index" do
    context "as JSON" do
      it "should find all users" do
        get :index, {format: :json}, session
        json = JSON.parse(response.body)
        expected = User.all.map {|x| {"id" => x.id, "name" => x.to_s}}
        (json | expected).eql?(json & expected).should be_true
      end

      it "should find matching users" do
        get :index, {format: :json, query: "adam"}, session
        json = JSON.parse(response.body)
        expected = [{"id" => @adam.id, "name" => @adam.to_s}]
        (json | expected).eql?(json & expected).should be_true
      end

      it "should exclude matching groups" do
        get :index, {format: :json, exclude_group_id: @group.id}, session
        json = JSON.parse(response.body)
        expected = (User.all - [@adam, @normin]).map {|x| {"id" => x.id, "name" => x.to_s}}
        (json | expected).eql?(json & expected).should be_true
      end
    end
  end

end

