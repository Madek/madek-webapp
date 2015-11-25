require 'spec_helper'

describe KeywordsController do
  let(:user) { FactoryGirl.create :user }
  let(:meta_key) { FactoryGirl.create :meta_key_keywords }

  context 'responds to search with json' do
    it 'filtering by params[:search_term]' do
      keywords = (1..2).map { FactoryGirl.create :keyword, meta_key: meta_key }
      keyword = keywords.sample
      keyword.meta_key.vocabulary.user_permissions << \
        create(:vocabulary_user_permission, user: user)

      get :index,
          { search_term: keyword.term,
            meta_key_id: meta_key.id,
            format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)

      expect(result.size).to be == 1
      expect(result.first['term']).to match /#{keyword.term}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryGirl.create :keyword, meta_key: meta_key }

      get :index, { meta_key_id: meta_key.id, limit: 1, format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryGirl.create :keyword, meta_key: meta_key }

      get :index, { meta_key_id: meta_key.id, format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end
  end
end
