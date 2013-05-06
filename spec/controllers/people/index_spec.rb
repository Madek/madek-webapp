require 'spec_helper'

describe PeopleController do
  render_views
  
  before :each do
    FactoryGirl.create :usage_term
    @user1 = FactoryGirl.create :user
    @user2= FactoryGirl.create :user, person: FactoryGirl.create(:person)
  end

  let :session do
    {user_id: @user1.id}
  end

  describe "GET index" do
    context "as JSON" do
      it "should find all users" do
        get :index, {format: :json}, session
        json = JSON.parse(response.body)
        expected = Person.all.map {|x| 
          {
            id: x.id,
            first_name: x.first_name,
            last_name: x.last_name,
            date_of_birth: x.date_of_birth,
            date_of_death: x.date_of_death,
            is_group: x.is_group,
            pseudonym: x.pseudonym           
          }
        }
        json.to_json.eql?(expected.to_json).should be_true
      end

      it "should find matching people" do
        get :index, {format: :json, query: @user2.person.first_name.downcase}, session
        json = JSON.parse(response.body)
        expected = [@user2.person].map {|x| 
          {
            id: x.id,
            first_name: x.first_name,
            last_name: x.last_name,
            date_of_birth: x.date_of_birth,
            date_of_death: x.date_of_death,
            is_group: x.is_group,
            pseudonym: x.pseudonym           
          }
        }
        json.to_json.eql?(expected.to_json).should be_true
      end
    end
  end


end

