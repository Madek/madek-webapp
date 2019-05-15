require 'spec_helper'

describe PeopleController do
  let(:user) { FactoryGirl.create :user }
  let(:meta_key_people) do
    FactoryGirl.create(:meta_key_people,
                       allowed_people_subtypes: ['Person'])
  end

  context 'Resource: People' do
    example 'Action: show - inits corresponding presenter' do
      person = FactoryGirl.create :person
      get :show, params: { id: person.id }, session: { user_id: user.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns[:get])
        .to be_instance_of(Presenters::People::PersonShow)
    end
  end

  context 'Resource: People - responds to search with json' do
    it 'filtering with params[:search_term] by first name' do
      2.times { FactoryGirl.create :person }
      person = Person.first

      get :index,
          params: {
            meta_key_id: meta_key_people.id,
            search_term: person.first_name,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['name']).to match /#{person.first_name}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryGirl.create :person }

      get :index,
          params: {
            meta_key_id: meta_key_people.id,
            limit: 1,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryGirl.create :person }

      get :index,
          params: {
            meta_key_id: meta_key_people.id,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end

    context 'prefers exact matches' do

      example 'by id' do
        2.times { FactoryGirl.create :person }
        person = Person.first
        # this person should not be returned even with the ID as a name:
        Person.last.last_name = person.id

        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: person.id,
              format: :json },
            session: { user_id: user.id }

        assert_response :success
        expect(response.content_type).to be == 'application/json'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['name']).to match /#{person.first_name}/
      end

      example 'by url' do
        2.times { FactoryGirl.create :person }
        person = Person.first
        # this person should not be returned even with the ID as a name:
        Person.last.last_name = person.id

        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: "https://example.com/people/#{person.id}/",
              format: :json },
            session: { user_id: user.id }

        assert_response :success
        expect(response.content_type).to be == 'application/json'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['name']).to match /#{person.first_name}/
      end

    end
  end
end
