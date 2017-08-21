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
      get :show, { id: person.id }, user_id: user.id

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
          { meta_key_id: meta_key_people.id,
            search_term: person.first_name,
            format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
      expect(result.first['name']).to match /#{person.first_name}/
    end

    it 'limiting with params[:limit]' do
      2.times { FactoryGirl.create :person }

      get :index,
          { meta_key_id: meta_key_people.id,
            limit: 1,
            format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 1
    end

    it 'with default limit of 100' do
      101.times { FactoryGirl.create :person }

      get :index,
          { meta_key_id: meta_key_people.id,
            format: :json },
          user_id: user.id

      assert_response :success
      expect(response.content_type).to be == 'application/json'
      result = JSON.parse(response.body)
      expect(result.size).to be == 100
    end
  end
end
