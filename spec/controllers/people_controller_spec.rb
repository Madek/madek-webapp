require 'spec_helper'

describe PeopleController do
  let(:user) { FactoryGirl.create :user }

  context 'responds to search with json' do
    it 'filtering by params[:search_term]' do
      2.times { FactoryGirl.create :user }
      person = Person.first

      get :index,
          { search_term: person.first_name, format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['name']).to match /#{person.first_name}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryGirl.create :person }

      get :index, { limit: 1, format: :json }, user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryGirl.create :person }

      get :index, { format: :json }, user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end
  end
end
