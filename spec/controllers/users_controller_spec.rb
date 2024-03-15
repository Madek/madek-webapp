require 'spec_helper'

describe UsersController do
  let(:user) { FactoryBot.create :user }
  before(:example) do
    5.times { FactoryBot.create :user }
  end

  context 'Resource: Users - responds to search with json' do
    it 'filtering with params[:search_term] by login' do
      get :index,
          params: {
            search_term: user.login,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['login']).to be == user.login
    end

    it 'filtering with params[:search_also_in_person] by person\'s first name' do
      get :index,
          params: {
            search_term: user.person.first_name,
            search_also_in_person: true,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['login']).to be == user.login
    end

    context 'prefers exact match' do

      it 'by id' do
        2.times { FactoryBot.create :user }
        user = User.first
        # this user should not be returned even with the ID as a login:
        User.last.login = user.id

        get :index,
            params: {
              search_term: user.id,
              format: :json },
            session: { user_id: user.id }

        assert_response :success
        expect(response.content_type).to be == 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['uuid']).to eq user.id
      end

      it 'by url' do
        2.times { FactoryBot.create :user }
        user = User.first
        # this user should not be returned even with the ID as a login:
        User.last.login = user.id

        get :index,
            params: {
              search_term: "https://example.com/admin/users/#{user.id}/",
              format: :json },
            session: { user_id: user.id }

        assert_response :success
        expect(response.content_type).to be == 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['uuid']).to eq user.id
      end

      it 'by email' do
        2.times { FactoryBot.create :user }
        user = User.first
        # this user should not be returned even with the email as a login:
        User.last.login = user.email.split('@').join(' ')

        get :index,
            params: {
              search_term: user.email,
              format: :json },
            session: { user_id: user.id }

        assert_response :success
        expect(response.content_type).to be == 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['uuid']).to eq user.id
      end

    end

    context 'when user is deactivated' do
      before { user.update_column(:active_until, Date.yesterday.to_datetime.end_of_day) }

      specify 'filtering by login does not return the user' do
        get :index,
            params: {
              search_term: user.login,
              format: :json },
            session: { user_id: user.id }

        expect(response).to be_successful
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result).to eq []
      end

      specify 'filtering by person\'s first name does not return the user' do
        get :index,
            params: {
              search_term: user.person.first_name,
              search_also_in_person: true,
              format: :json },
            session: { user_id: user.id }

        expect(response).to be_successful
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result).to eq []
      end
    end
  end
end
