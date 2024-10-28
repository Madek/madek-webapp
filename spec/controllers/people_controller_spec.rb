require 'spec_helper'

describe PeopleController do
  let(:user) { FactoryBot.create :user }
  let(:person) { user.person }
  let(:meta_key_people) do
    FactoryBot.create(:meta_key_people,
                       allowed_people_subtypes: ['Person'])
  end

  before(:each) do
    AppSetting.first.presence || create(:app_setting)
  end

  context 'Resource: People' do
    example 'Action: show - inits corresponding presenter' do
      person = FactoryBot.create :person
      get :show, params: { id: person.id }, session: { user_id: user.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns[:get])
        .to be_instance_of(Presenters::People::PersonShow)
    end

    context 'when previous id was passed' do
      it 'redirects to current person page' do
        previous_obj = create(:person)
        current_obj = create(:person)

        previous_obj.merge_to(current_obj)

        get(:show, params: { id: previous_obj.id }, session: { user_id: user.id })

        expect(response).to redirect_to(person_path(current_obj))
      end
    end
  end

  context 'Resource: People - responds to search with json' do
    it 'filtering with params[:search_term] by first name' do
      2.times { FactoryBot.create :person }
      person = Person.first

      get :index,
          params: {
            meta_key_id: meta_key_people.id,
            search_term: person.first_name,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['name']).to match /#{person.first_name}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryBot.create :person }

      get :index,
          params: {
            meta_key_id: meta_key_people.id,
            limit: 1,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryBot.create :person }

      get :index,
          params: {
            meta_key_id: meta_key_people.id,
            format: :json },
          session: { user_id: user.id }

      assert_response :success
      expect(response.content_type).to be == 'application/json; charset=utf-8'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end

    context 'prefers exact matches' do

      example 'by id' do
        2.times { FactoryBot.create :person }
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
        expect(response.content_type).to be == 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['name']).to match /#{person.first_name}/
      end

      example 'by url' do
        2.times { FactoryBot.create :person }
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
        expect(response.content_type).to be == 'application/json; charset=utf-8'
        result = JSON.parse(response.body)
        expect(result.size).to be == 1
        expect(result.first['name']).to match /#{person.first_name}/
      end

    end

    context 'delivers person info according to app settings' do
      before(:each) do
        FactoryBot.create :person, identification_info: 'cool', institution: 'moma', institutional_id: '123', last_name: 'SmithX77'
      end

      example 'default' do
        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: 'SmithX77',
              limit: 1,
              format: :json },
            session: { user_id: user.id }
        assert_response :success
        p = JSON.parse(response.body).first
        expect(p['info']).to eq 'cool'
      end

      example 'no info' do
        AppSetting.first.update person_info_fields: []

        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: 'SmithX77',
              limit: 1,
              format: :json },
            session: { user_id: user.id }
        assert_response :success
        p = JSON.parse(response.body).first
        expect(p['info']).to be_nil
      end

      example 'with institutional id' do
        AppSetting.first.update person_info_fields: ['institutional_id']

        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: 'SmithX77',
              limit: 1,
              format: :json },
            session: { user_id: user.id }
        assert_response :success
        p = JSON.parse(response.body).first
        expect(p['info']).to eq 'moma 123'
      end

      example 'with identification info' do
        AppSetting.first.update person_info_fields: ['identification_info']

        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: 'SmithX77',
              limit: 1,
              format: :json },
            session: { user_id: user.id }
        assert_response :success
        p = JSON.parse(response.body).first
        expect(p['info']).to eq 'cool'
      end

      example 'with both' do
        AppSetting.first.update person_info_fields: ['institutional_id', 'identification_info']

        get :index,
            params: {
              meta_key_id: meta_key_people.id,
              search_term: 'SmithX77',
              limit: 1,
              format: :json },
            session: { user_id: user.id }
        assert_response :success
        p = JSON.parse(response.body).first
        expect(p['info']).to eq 'moma 123 - cool'
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
          pseudonym: Faker::Artist.name,
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
