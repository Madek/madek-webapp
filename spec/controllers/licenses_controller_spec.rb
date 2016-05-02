require 'spec_helper'

describe LicensesController do
  let(:user) { FactoryGirl.create :user }

  context 'Resource: Licenses – responds to search with json' do
    it 'filtering with params[:search_term] by label' do
      5.times { FactoryGirl.create :license }
      license = License.last

      get :index,
          { search_term: license.label, format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['label']).to match /#{license.label}/
    end

    it 'filtering with params[:search_term] by url' do
      5.times { FactoryGirl.create :license }
      license = License.last

      get :index,
          { search_term: license.url, format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['label']).to match /#{license.label}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryGirl.create :license }

      get :index, { limit: 1, format: :json }, user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryGirl.create :license }

      get :index, { format: :json }, user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end
  end
end
