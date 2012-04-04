require 'spec_helper'

describe PeopleController do
  render_views
  
  before :all do
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
            firstname: x.firstname,
            lastname: x.lastname,
            birthdate: x.birthdate,
            deathdate: x.deathdate,
            is_group: x.is_group,
            nationality: x.nationality,
            pseudonym: x.pseudonym           
          }
        }
        json.to_json.eql?(expected.to_json).should be_true
      end

      it "should find matching people" do
        get :index, {format: :json, query: @user2.person.firstname.downcase}, session
        json = JSON.parse(response.body)
        expected = [@user2.person].map {|x| 
          {
            id: x.id,
            firstname: x.firstname,
            lastname: x.lastname,
            birthdate: x.birthdate,
            deathdate: x.deathdate,
            is_group: x.is_group,
            nationality: x.nationality,
            pseudonym: x.pseudonym           
          }
        }
        json.to_json.eql?(expected.to_json).should be_true
      end
    end
  end


end

