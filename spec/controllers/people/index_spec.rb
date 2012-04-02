require 'spec_helper'

describe PeopleController do
  render_views
  
  before :all do
    @normin = FactoryGirl.create :user, login: "normin"
    @adam= FactoryGirl.create :user, login: "adam", 
      person: FactoryGirl.create(:person, firstname: "Adam"  )
  end

  let :session do
    {user_id: @normin.id}
  end

  describe "GET index" do
    context "as JSON" do
      it "should find all users" do
        get :index, {format: :json}, session
        json = JSON.parse(response.body)
        expected = Person.all.map {|x| {"id" => x.id, "name" => x.to_s}}
        (json | expected).eql?(json & expected).should be_true
      end

      it "should find matching people" do
        get :index, {format: :json, query: "adam"}, session
        json = JSON.parse(response.body)
        expected = [{"id" => @adam.person.id, "name" => @adam.person.to_s}]
        (json | expected).eql?(json & expected).should be_true
      end
    end
  end


end

