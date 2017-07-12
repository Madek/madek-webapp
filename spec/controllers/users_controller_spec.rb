require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create :user }
  before(:example) do
    5.times { FactoryGirl.create :user }
  end

  context 'Resource: Users - responds to search with json' do
    it 'filtering with params[:search_term] by login' do
      get :index,
          search_term: user.login,
          format: :json

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['login']).to be == user.login
    end

    it 'filtering with params[:search_also_in_person] by person\'s first name' do
      get :index,
          search_term: user.person.first_name,
          search_also_in_person: true,
          format: :json

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['login']).to be == user.login
    end

    context 'when user is deactivated' do
      before { user.update_column(:is_deactivated, true) }

      specify 'filtering by login does not return the user' do
        get :index,
            search_term: user.login,
            format: :json

        expect(response).to be_success
        expect(response.content_type).to eq 'application/json'
        result = JSON.parse(response.body)
        expect(result).to eq []
      end

      specify 'filtering by person\'s first name does not return the user' do
        get :index,
            search_term: user.person.first_name,
            search_also_in_person: true,
            format: :json

        expect(response).to be_success
        expect(response.content_type).to eq 'application/json'
        result = JSON.parse(response.body)
        expect(result).to eq []
      end
    end
  end
end
