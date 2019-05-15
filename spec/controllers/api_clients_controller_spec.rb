require 'spec_helper'

describe ApiClientsController do
  let(:user) { FactoryGirl.create :user }

  context 'responds to search with json' do
    it 'filtering by params[:search_term]' do
      2.times { FactoryGirl.create :api_client }

      api_client = ApiClient.first

      get :index,
          params: { search_term: api_client.login, format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['login']).to match /#{api_client.login}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryGirl.create :api_client }

      get(
        :index,
        params: { limit: 1, format: :json },
        session: { user_id: user.id })

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryGirl.create :api_client }

      get :index, params: { format: :json }, session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end
  end
end
