require 'spec_helper'

describe PeopleController do
  let(:user) { FactoryGirl.create :user }
  let(:person) { user.person }
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

  describe '#edit' do
    context 'when user is not logged in' do
      it 'raises error' do
        expect { get(:edit, params: { id: person.id }) }
          .to raise_error(Errors::UnauthorizedError)
      end
    end

    context 'when user is a person owner' do
      it 'renders template' do
        get(:edit, params: { id: person.id }, session: { user_id: user.id })

        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not a person owner' do
      let(:another_user) { create :user }

      it 'raises error' do
        expect do
          get(
            :edit,
            params: { id: person.id },
            session: { user_id: another_user.id }
          )
        end.to raise_error(Errors::ForbiddenError)
      end
    end

    context 'when user is an admin' do
      let(:admin) { create :admin_user }
      let(:session_hash) { { user_id: admin.id, uberadmin_mode: true } }

      it 'renders template for common user' do
        get(:edit, params: { id: person.id }, session: session_hash)

        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#update' do
    let(:params) do
      {
        id: person.id,
        person: {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          pseudonym: Faker::Name.title,
          description: Faker::Lorem.paragraph,
          external_uris: [
            Faker::Internet.url,
            Faker::Internet.url
          ]
        }
      }
    end

    context 'when user is not logged in' do
      it 'raises error' do
        expect { patch(:update, params: params) }
          .to raise_error(Errors::UnauthorizedError)
      end
    end

    context 'when user is a person owner' do
      it 'redirects to show' do
        patch(:update, params: params, session: { user_id: user.id })

        expect(response).to redirect_to(person_path(person))
        expect(response).to have_http_status(302)
      end
    end

    context 'when user is not a person owner' do
      let(:another_user) { create :user }

      it 'raises error' do
        expect do
          patch(
            :update,
            params: params,
            session: { user_id: another_user.id }
          )
        end.to raise_error(Errors::ForbiddenError)
      end
    end

    context 'when user is an admin' do
      let(:admin) { create :admin_user }
      let(:session_hash) { { user_id: admin.id, uberadmin_mode: true } }

      it 'renders template for common user' do
        get(:edit, params: { id: person.id }, session: session_hash)

        expect(response).to render_template(:edit)
      end
    end
  end
end
