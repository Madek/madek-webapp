require 'spec_helper'

describe PeopleController do
  let(:user) { FactoryGirl.create :user }

  context 'Resource: People' do
    example 'Action: show – redirects to filtered index' do
      person = FactoryGirl.create :person
      get :show, { id: person.id }, user_id: user.id
      expect(response).to redirect_to(
        'http://test.host/entries?list%5Bfilter%5D=' \
        + '%7B%22meta_data%22%3A%5B%7B%22key%22%3A%22any%22%2C%22value%22%3A%22' \
        + person.id \
        + '%22%2C%22type%22%3A%22MetaDatum%3A%3APeople%22%7D%5D%7D' \
        + '&list%5Bshow_filter%5D=true')
    end
  end

  context 'Resource: People - responds to search with json' do
    it 'filtering with params[:search_term] by first name' do
      2.times { FactoryGirl.create :person }
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
