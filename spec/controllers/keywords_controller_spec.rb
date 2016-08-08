require 'spec_helper'

describe KeywordsController do
  let(:user) { FactoryGirl.create :user }
  let(:meta_key) { FactoryGirl.create :meta_key_keywords }
  let(:meta_datum_keywords) do
    FactoryGirl.create(:meta_datum_keywords, meta_key: meta_key)
  end

  context 'Resource: Keywords' do
    example \
      'Action: show *by `meta_key` and `term`* – redirects to filtered index' do
      keyword = FactoryGirl.create :keyword, meta_key: meta_key

      get :show, { term: keyword.term, meta_key_id: meta_key }, user_id: user.id

      expect(response).to redirect_to('http://test.host/entries?' + {
        list: {
          filter: JSON.generate(
            meta_data: [{
              key: meta_key.id,
              value: keyword.id,
              type: 'MetaDatum::Keywords' }]),
          show_filter: true }
      }.to_query)
    end

    it 'action show responds with 403 if user not authorized' do
      vocab = FactoryGirl.create(:vocabulary,
                                 id: Faker::Lorem.characters(8),
                                 enabled_for_public_view: false)
      meta_key_keywords = \
        FactoryGirl.create(:meta_key_keywords,
                           id: "#{vocab.id}:#{Faker::Lorem.characters(8)}")
      meta_datum_keywords = \
        FactoryGirl.create(:meta_datum_keywords,
                           meta_key: meta_key_keywords)
      keyword = meta_datum_keywords.keywords.first

      expect do
        get :show,
            { term: keyword.term, meta_key_id: meta_key_keywords },
            user_id: user.id
      end.to raise_error Errors::ForbiddenError
    end
  end

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
      expect(result.first['label']).to match /#{keyword.term}/
    end

    it 'order by last used DESC' do
      meta_key.vocabulary.user_permissions << \
        create(:vocabulary_user_permission, user: user)

      mdk1 = FactoryGirl.create(:meta_datum_keyword,
                                meta_datum: meta_datum_keywords,
                                created_by: user,
                                created_at: Date.today)
      mdk2 = FactoryGirl.create(:meta_datum_keyword,
                                meta_datum: meta_datum_keywords,
                                created_by: user,
                                created_at: Date.yesterday)
      mdk3 = FactoryGirl.create(:meta_datum_keyword,
                                meta_datum: meta_datum_keywords,
                                created_by: user,
                                created_at: Date.today - 1.week)

      (1..2).map { FactoryGirl.create :meta_datum_keyword }

      get :index,
          { used_by_id: user.id,
            meta_key_id: meta_key.id,
            format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)

      expect(result.size).to be == 3
      expect(result.map { |h| h['uuid'] })
        .to be == [mdk1, mdk2, mdk3].map(&:keyword).map(&:id)
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
