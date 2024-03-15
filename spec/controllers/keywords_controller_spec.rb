require 'spec_helper'
require 'spec_helper_shared'

describe KeywordsController do
  let(:user) { FactoryBot.create :user }
  let(:meta_key) { FactoryBot.create :meta_key_keywords }
  let(:meta_datum_keywords) do
    FactoryBot.create(:meta_datum_keywords, meta_key: meta_key)
  end

  context 'Resource: Keywords' do
    example \
      'action redirect_by_term works if user is authorized' do
      keyword = FactoryBot.create :keyword, meta_key: meta_key
      get(
        :redirect_by_term,
        params: { term: keyword.term, meta_key_id: meta_key },
        session: { user_id: user.id }
      )
      assert_response 302
      expect(URI(response.redirect_url).path).to eq(
        vocabulary_meta_key_term_show_path(keyword.id))
    end

    example \
      'action show works if user is authorized' do
      keyword = FactoryBot.create :keyword, meta_key: meta_key
      get(
        :show,
        params: { keyword_id: keyword.id },
        session: { user_id: user.id })
      assert_response 200
    end

    it 'action show responds with 403 if user not authorized' do
      vocab = FactoryBot.create(:vocabulary,
                                 id: Faker::Lorem.characters(number: 8),
                                 enabled_for_public_view: false)
      meta_key_keywords = \
        FactoryBot.create(:meta_key_keywords,
                           id: "#{vocab.id}:#{Faker::Lorem.characters(number: 8)}")
      meta_datum_keywords = \
        FactoryBot.create(:meta_datum_keywords,
                           meta_key: meta_key_keywords)
      keyword = meta_datum_keywords.keywords.first

      expect do
        get(
          :show,
          params: { keyword_id: keyword.id },
          session: { user_id: user.id })
      end.to raise_error Errors::ForbiddenError
    end

    context 'when previous id was passed' do
      it 'redirects to current keyword page' do
        previous_obj = create(:keyword)
        current_obj = create(:keyword)

        previous_obj.merge_to(current_obj)

        get(:show, params: { keyword_id: previous_obj.id }, session: { user_id: user.id })

        expect(response).to redirect_to(vocabulary_meta_key_term_show_path(current_obj))
      end
    end
  end

  context 'responds to search with json' do
    it 'filtering by params[:search_term]' do
      keywords = (1..2).map { FactoryBot.create :keyword, meta_key: meta_key }
      keyword = keywords.sample
      keyword.meta_key.vocabulary.user_permissions << \
        create(:vocabulary_user_permission, user: user)

      get :index,
          params: {
            search_term: keyword.term,
            meta_key_id: meta_key.id,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)

      expect(result.size).to be == 1
      expect(result.first['label']).to match /#{keyword.term}/
    end

    it 'sorts the keywords according to match relevance' do
      # the match relevance is determined according to following criteria:
      # 1. case sensitive full match
      # 2. case insensitive full match
      # 3. term beginning with string
      # 4. position of string inside of term
      # 5. in case of same position then alphabetic

      #truncate_tables
      #restore_seeds

      vocab = FactoryBot.create(:vocabulary,
                                 id: Faker::Lorem.characters(number: 5),
                                 enabled_for_public_view: true)
      meta_key = \
        FactoryBot.create(:meta_key,
                           id: "#{vocab.id}:#{Faker::Lorem.characters(number: 8)}")
      labels = %w(Pinsir
                  Pidgeot
                  Rapidash
                  Pidgey
                  Weepinbell
                  Caterpie
                  Pikachu
                  Vulpix
                  Pi
                  pi
                  Pidgeotto)
      labels.map do |label|
        FactoryBot.create(:keyword, meta_key: meta_key, term: label)
      end
      sorted_labels = %w(pi
                         Pi
                         Pidgeot
                         Pidgeotto
                         Pidgey
                         Pikachu
                         Pinsir
                         Rapidash
                         Vulpix
                         Weepinbell
                         Caterpie)
      get :index,
          params: {
            search_term: 'pi',
            meta_key_id: meta_key.id,
            format: :json },
          session: { user_id: user.id }

      result = JSON.parse(response.body)
      expect(result.map { |k| k['label'] }).to be == sorted_labels
    end

    it 'order by last used DESC' do
      meta_key.vocabulary.user_permissions << \
        create(:vocabulary_user_permission, user: user)

      mdk1 = FactoryBot.create(:meta_datum_keyword,
                                meta_datum: meta_datum_keywords,
                                created_by: user,
                                created_at: Date.today)
      mdk2 = FactoryBot.create(:meta_datum_keyword,
                                meta_datum: meta_datum_keywords,
                                created_by: user,
                                created_at: Date.yesterday)
      mdk3 = FactoryBot.create(:meta_datum_keyword,
                                meta_datum: meta_datum_keywords,
                                created_by: user,
                                created_at: Date.today - 1.week)

      (1..2).map { FactoryBot.create :meta_datum_keyword }

      get :index,
          params: {
            used_by_id: user.id,
            meta_key_id: meta_key.id,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)

      expect(result.size).to be == 3
      expect(result.map { |h| h['uuid'] })
        .to be == [mdk1, mdk2, mdk3].map(&:keyword).map(&:id)
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryBot.create :keyword, meta_key: meta_key }

      get :index,
          params: { meta_key_id: meta_key.id, limit: 1, format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryBot.create :keyword, meta_key: meta_key }

      get :index,
          params: { meta_key_id: meta_key.id, format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end
  end
end
